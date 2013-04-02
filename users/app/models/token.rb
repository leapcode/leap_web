class Token < CouchRest::Model::Base

  use_database :tokens

  property :user_id, String, accessible: false

  validates :user_id, presence: true

end

