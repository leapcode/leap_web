class Message < CouchRest::Model::Base

  use_database :messages

  property :text, String

  design do
  end

end
