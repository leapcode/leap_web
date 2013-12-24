class UserMessage < CouchRest::Model::Base

  use_database :user_messages
  belongs_to :user
  belongs_to :message

  validates :user_id, presence: true
  validates :message_id, presence: true


  property :seen, TrueClass, :default => false

  design do
    view :by_user_id
    view :by_message_id
    view :by_user_id_and_seen
    own_path = Pathname.new(File.dirname(__FILE__))
    load_views(own_path.join('..', 'designs', 'user_message'))

  end

end
