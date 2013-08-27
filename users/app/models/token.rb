class Token < CouchRest::Model::Base

  use_database :tokens

  property :user_id, String, accessible: false

  validates :user_id, presence: true

  def user
    User.find(self.user_id)
  end

  def initialize(*args)
    super
    self.id = SecureRandom.urlsafe_base64(32).gsub(/^_*/, '')
  end

  design do
  end
end

