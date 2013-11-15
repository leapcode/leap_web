class Token < CouchRest::Model::Base

  use_database :tokens

  belongs_to :user

  # timestamps! does not create setters and only sets updated_at
  # if the object has changed and been saved. Instead of triggering
  # that we rather use our own property we have control over:
  property :last_seen_at, Time, accessible: false

  validates :user_id, presence: true

  design do
    view :by_last_seen_at
  end

  def self.expires_after
    APP_CONFIG[:auth] && APP_CONFIG[:auth][:token_expires_after]
  end

  def self.expired
    return [] unless expires_after
    by_last_seen_at.endkey(expires_after.minutes.ago)
  end

  def self.destroy_all_expired
    self.expired.each do |token|
      token.destroy
    end
  end

  def authenticate
    if expired?
      destroy
      return nil
    else
      touch
      return user
    end
  end

  def touch
    self.last_seen_at = Time.now
    save
  end

  def expired?
    Token.expires_after and
    last_seen_at < Token.expires_after.minutes.ago
  end

  def initialize(*args)
    super
    if new_record?
      self.id = SecureRandom.urlsafe_base64(32).gsub(/^_*/, '')
      self.last_seen_at = Time.now
    end
  end
end

