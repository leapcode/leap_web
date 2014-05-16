class Message < CouchRest::Model::Base

  use_database :messages

  property :text, String
  property :user_ids_to_show, [String]
  property :user_ids_have_shown, [String] # is this necessary to store?

  timestamps!

  design do
    own_path = Pathname.new(File.dirname(__FILE__))
    load_views(own_path.join('..', 'designs', 'message'))
  end

  def mark_as_read_by(user)
    user_ids_to_show.delete(user.id)
    # is it necessary to keep track of what users have already seen it?
    user_ids_have_shown << user.id unless read_by?(user)
  end

  def read_by?(user)
    user_ids_have_shown.include?(user.id)
  end

  def unread_by?(user)
    user_ids_to_show.include?(user.id)
  end
end
