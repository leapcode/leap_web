class Email < String
=begin
  included do
    validates :email,
      :format => {
        :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/,
        :message => "needs to be a valid email address"
      }
  end
=end

  def to_partial_path
    "emails/email"
  end

  def to_param
    to_s
  end

end
