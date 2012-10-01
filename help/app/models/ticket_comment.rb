class TicketComment < CouchRest::Model::Base #?? do we want this to be a base model? 
  include CouchRest::Model::Embeddable 

  #use_database "ticket_comments"

  #belongs_to :ticket #is this best way to do it? will want to access all of a tickets comments, so maybe this isn't the way?
  property :posted_by, Integer, :protected => true# maybe this should be current_user if that is set, meaning the user is logged in  #String # user??
  # if the current user is not set, then we could just say the comment comes from an 'unauthenticated user', which would be somebody with the secret URL
  property :posted_at, Time, :protected => true
  #property :posted_verified, TrueClass, :protected => true #should be true if current_user is set when the comment is created
  property :body, String

  before_validation :set_time, :set_posted_by, :on => :create # hmm, this requires object to be validated for these methods to be called, but if this is only embeddedable (which might be best), then not clear how to do this without manually validating.

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
  
  def set_posted_by
    #should be something like this, but current_user is not set yet
    #self.posted_by = current_user if current_user
  end

end
