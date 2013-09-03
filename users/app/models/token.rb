class Token < CouchRest::Model::Base

  use_database :tokens

  belongs_to :user

  # timestamps! does not create setters and only sets updated_at
  # if the object has changed and been saved. Instead of triggering
  # that we rather use our own property we have control over:
  property :last_seen_at, Time, accessible: false

  validates :user_id, presence: true

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
    expires_after and
    last_seen_at + expires_after.minutes < Time.now
  end

  def expires_after
    APP_CONFIG[:auth] && APP_CONFIG[:auth][:token_expires_after]
  end

  def initialize(*args)
    super
    self.id = SecureRandom.urlsafe_base64(32).gsub(/^_*/, '')
    self.last_seen_at = Time.now
  end

  design do
  end
end

