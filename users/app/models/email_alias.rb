class EmailAlias
  include CouchRest::Model::Embeddable

  property :email, String
  timestamps!
end
