#
# elijah: the property 'posted_by' should have been a belongs_to() association
#         or at least 'posted_by_id', but I am leaving it as is because I am
#         not sure how to change it.
#
class TicketComment
  include CouchRest::Model::Embeddable

  property :posted_by, String
  property :posted_at, Time
  property :body, String
  property :private, TrueClass

  validates :body, :presence => true

  # translations are in the same scope as those of a "proper" couchrest model
  def self.i18n_scope
    "couchrest"
  end

  def is_comment_validated?
    !!posted_by
  end

  def posted_by_user
    if posted_by
      @_posted_by_user ||= User.find(posted_by)
    end
  end
  alias user posted_by_user

end
