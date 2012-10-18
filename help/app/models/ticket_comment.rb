class TicketComment
  include CouchRest::Model::Embeddable 

  #belongs_to :ticket #is this best way to do it? will want to access all of a tickets comments, so maybe this isn't the way?
  property :posted_by, String#, :protected => true #Integer#this should be current_user if that is set, meaning the user is logged in  #cannot have it be protected and set via comments_attributes=. also, if it is protected and we set in the tickets_controller, it gets unset. TODO---is this okay to have it not protected and manually check it? We do not users to be able to set this.
  # if the current user is not set, then we could just say the comment comes from an 'unauthenticated user', which would be somebody with the secret URL
  property :posted_at, Time#, :protected => true
  #property :posted_verified, TrueClass, :protected => true #should be true if current_user is set when the comment is created
  property :body, String

  # ? timestamps!
  validates :body, :presence => true
  #before_validation :set_time#, :set_posted_by

  #design do
  #  view :by_posted_at
  #  view :by_body
  #end

  def is_comment_validated?
    !!posted_by
  end

=begin
  #TODO. 
  #this is resetting all comments associated with the ticket:
  def set_time
    self.posted_at = Time.now
  end
=end
  
=begin
  def set_posted_by
    self.posted_by = User.current if User.current
  end
=end

end
