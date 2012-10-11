class TicketComment
  include CouchRest::Model::Embeddable 

  #belongs_to :ticket #is this best way to do it? will want to access all of a tickets comments, so maybe this isn't the way?
  property :posted_by, Integer, :protected => true# maybe this should be current_user if that is set, meaning the user is logged in  #String # user??
  # if the current user is not set, then we could just say the comment comes from an 'unauthenticated user', which would be somebody with the secret URL
  property :posted_at, Time, :protected => true
  #property :posted_verified, TrueClass, :protected => true #should be true if current_user is set when the comment is created
  property :body, String

  before_validation :set_time#, :set_posted_by

  #design do
  #  view :by_posted_at
  #  view :by_body
  #end

  def is_comment_validated?
    !!posted_by
  end
 
  def set_time
    self.posted_at = Time.now
  end
  
=begin
  def set_posted_by
    self.posted_by = User.current if User.current
  end
=end

end
