class Token < CouchRest::Model::Base

  use_database :tokens

  belongs_to :user

  validates :user_id, presence: true

  def initialize(*args)
    super
    self.id = SecureRandom.urlsafe_base64(32).gsub(/^_*/, '')
  end

  design do
  end
end

