class Message < CouchRest::Model::Base

  use_database :messages

  property :text, String
  property :user_ids_to_show, [String]
  property :user_ids_have_shown, [String] # is this necessary to store?

  design do
    own_path = Pathname.new(File.dirname(__FILE__))
    load_views(own_path.join('..', 'designs', 'message'))
  end

end
