#
# TODO: thought i should reverse keys for descending, but that didn't work.
# look into whether that should be tweaked, and whether it works okay with
# pagination (seems to now...)
#
# TODO: better validation of email
#
# TODO: don't hardcode strings 'unknown user' and 'unauthenticated user'
#
class Ticket < CouchRest::Model::Base
  use_database "tickets"

  property :created_by,     String, :protected => true  # nil for anonymous tickets, should never be changed
  property :regarding_user, String                      # may be nil or valid username
  property :title,          String
  property :email,          String
  property :is_open,        TrueClass, :default => true
  property :comments,       [TicketComment]

  timestamps!

  before_validation :set_email, :set_regarding_user, :on => :create

  design do
    view :by_updated_at
    view :by_created_at

    view :by_is_open_and_created_at
    view :by_is_open_and_updated_at

    own_path = Pathname.new(File.dirname(__FILE__))
    load_views(own_path.join('..', 'designs', 'ticket'))
  end

  validates :title, :presence => true
  validates :email, :allow_blank => true, :format => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/

  def self.search(options = {})
    @selection = TicketSelection.new(options)
    @selection.tickets
  end

  def is_creator_validated?
    !!created_by
  end

  def set_email
    self.email = nil if self.email == ""
  end

  def set_regarding_user
    self.regarding_user = nil if self.regarding_user == ""
  end

  def close
    self.is_open = false
  end

  def reopen
    self.is_open = true
  end

  def commenters
    commenters = []
    self.comments.each do |comment|
      if comment.posted_by
        if user = User.find(comment.posted_by)
          commenters << user.login if user and !commenters.include?(user.login)
        else
          commenters << 'unknown user' if !commenters.include?('unknown user')
        end
      else
        commenters << 'unauthenticated user' if !commenters.include?('unauthenticated user')
      end
    end
    commenters.join(', ')
  end

  #
  # update comments. User should be set by controller.
  #
  def comments_attributes=(attributes)
    if attributes
      comment = TicketComment.new(attributes.values.first)
      comment.posted_at = Time.now
      comments << comment
    end
  end

  def created_by_user
    User.find(self.created_by)
  end

  def regarding_user_actual_user
    User.find_by_login(self.regarding_user)
  end

end
