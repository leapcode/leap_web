class Ticket < CouchRest::Model::Base
  #include ActiveModel::Validations

  use_database "tickets"
  require 'securerandom'
=begin
    title
    created_at
    updated_at
    email_address
    user
    user_verified?
    admins (list of admins who have commented on the ticket)
    code (secret url)
=end

  #belongs_to :user #from leap_web_users. doesn't necessarily belong to a user though
  property :created_by, String, :protected => true #Integer #nil unless user was authenticated for ticket creation, #THIS should not be changed after being set
  #property :regarding_user, String#Integer # form cannot be submitted if they type in a username w/out corresponding ID. this field can be nil. for authenticated ticket creation by non-admins, should this just automatically be set to be same as created_by?  or maybe we don't use this field unless created_by is nil?
  #also, both created_by and regarding_user could be nil---say user forgets username, or has general question
  property :title, String
  property :email, String #verify

  #property :user_verified, TrueClass, :default => false #will be true exactly when user is set
  #admins
  #property :code, String, :protected => true # only should be set if created_by is nil #instead we will just use couchdb ID
  property :is_open, TrueClass, :default => true
  property :comments, [TicketComment]

  timestamps!

  #before_validation :set_created_by, :set_code, :set_email, :on => :create
  before_validation :set_email, :on => :create


  #named_scope :open, :conditions => {:is_open => true} #??

  design do
    #TODO--clean this all up
    #view :by_is_open
    #view :by_created_by

    view :by_updated_at
    view :by_created_at

    #view :by_is_open_and_created_by
    view :by_is_open_and_created_at
    view :by_is_open_and_updated_at

    load_views(Rails.root.join('help', 'app', 'designs', 'ticket'))
  end

  validates :title, :presence => true
  #validates :comments, :presence => true #do we want it like this?


  # html5 has built-in validation which isn't ideal, as it says 'please enter an email address' for invalid email addresses, which implies an email address is required, and it is not.
  validates :email, :format => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/, :if => :email #email address is optional

  #TODO:
  #def set_created_by
  #  self.created_by = User.current if User.current
  #end

  def self.for_user(user, options = {}, is_admin = false)

    # TODO: thought i  should reverse keys for descending, but that didn't work. look into whether that should be tweaked, and whether it works okay with pagination (seems to now...)

    options[:user_id] = user.id
    options[:is_admin] = is_admin

    @selection = TicketSelection.new(options)
    @selection.tickets
  end

  #def self.tickets_by_commenter(user_id)#, options = {})
  #  Ticket.includes_post_by_and_updated_at.startkey([user_id, 0]).endkey([user_id, Time.now])
  #end

  def is_creator_validated?
    !!created_by
  end

=begin
  def set_code #let's not use this---can use same show url
    # ruby 1.9 provides url-safe option---this is not necessarily url-safe
    self.code = SecureRandom.hex(8) if !is_creator_validated?
  end
=end


  def set_email
    self.email = nil if self.email == ""
    # in controller set to be current users email if that exists
  end

  #not saving with close and reopen, as we will save in update when they are called.
  #TODO: not sure if we should bother with these:
  def close
    self.is_open = false
    #save
  end

  def reopen
    self.is_open = true
    #save
  end

  def commenters
    commenters = []
    self.comments.each do |comment|
      if comment.posted_by
        if user = User.find(comment.posted_by)
          commenters << user.login if user and !commenters.include?(user.login)
        else
          commenters << 'unknown user' if !commenters.include?('unknown user') #todo don't hardcode string 'unknown user'
        end
      else
        commenters << 'unauthenticated user' if !commenters.include?('unauthenticated user') #todo don't hardcode string 'unauthenticated user'
      end
    end
    commenters.join(', ')
  end

  def comments_attributes=(attributes)
    if attributes # could be empty as we will empty if nothing was typed in
      comment = TicketComment.new(attributes.values.first) #TicketComment.new(attributes)
      #comment.posted_by = User.current.id if User.current #we want to avoid User.current, and current_user won't work here. instead will set in tickets_controller
      # what about: comment.posted_by = self.updated_by  (will need to add ticket.updated_by)
      comment.posted_at = Time.now
      comments << comment
    end
  end

=begin
  def validate
    if email_address and not email_address.strip =~ RFC822::EmailAddress
      errors.add 'email', 'contains an invalid address'
    end
  end
=end
end
