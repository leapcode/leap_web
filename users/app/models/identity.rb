class Identity < CouchRest::Model::Base

  use_database :identities

  belongs_to :user

  property :address
  property :destination

  design do
    view :by_user_id
  end
end
