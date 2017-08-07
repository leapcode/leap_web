require 'digest/sha2'

class Token < CouchRest::Model::Base
  def self.expires_after
    APP_CONFIG[:auth] && APP_CONFIG[:auth][:token_expires_after]
  end

  include CouchRest::Model::Rotation
  rotate_database :tokens,
    :every => 1.month,
    :timestamp_field => :last_seen_at,
    :timeout => self.expires_after.to_i # in minutes

  belongs_to :user

  # timestamps! does not create setters and only sets updated_at
  # if the object has changed and been saved. Instead of triggering
  # that we rather use our own property we have control over:
  property :last_seen_at, Time, accessible: false

  validates :user_id, presence: true

  attr_accessor :token

  design do
    view :by_last_seen_at
  end

  def self.find_by_token(token)
    self.find Digest::SHA512.hexdigest(token)
  end

  def self.expired
    return [] unless expires_after
    by_last_seen_at.endkey(expires_after.minutes.ago)
  end

  def self.to_cleanup
    return [] unless expires_after
    by_last_seen_at.endkey((expires_after + 5).minutes.ago)
  end

  def self.destroy_all_expired
    self.to_cleanup.each do |token|
      token.destroy
    end
  end

  def to_s
    token
  end

  def authenticate
    return if expired?
    touch
    return user
  rescue CouchRest::NotFound
    # Reload in touch failed - token has been deleted.
    # That's either an active logout or account destruction.
    # We don't accept the token anymore.
  end

  # Tokens can be cleaned up in different ways.
  # So let's make sure we don't crash if they disappeared
  def destroy_with_rescue
    destroy_without_rescue
  rescue CouchRest::Conflict # do nothing - it's been updated - #7670
    try_to_reload && retry
  rescue CouchRest::NotFound
  end
  alias_method_chain :destroy, :rescue

  def touch
    update_attributes last_seen_at: Time.now
  rescue CouchRest::Conflict
    reload && retry
  end

  def expired?
    Token.expires_after and
    last_seen_at < Token.expires_after.minutes.ago
  end

  def initialize(*args)
    super
    if new_record?
      self.token = SecureRandom.urlsafe_base64(32).gsub(/^_*/, '')
      self.id = Digest::SHA512.hexdigest(self.token)
      self.last_seen_at = Time.now
    end
  end

  # UPGRADE: the underlying code here changes between CouchRest::Model
  # 2.1.0.rc1 and 2.2.0.beta2
  # Hopefully we'll also get a pr merged that pushes this workaround
  # upstream:
  # https://github.com/couchrest/couchrest_model/pull/223
  def reload
    prepare_all_attributes(
      database.get!(id), :directly_set_attributes => true
    )
    self
  end

  protected

  def try_to_reload
    reload
  rescue CouchRest::NotFound
    return false
  end

end
