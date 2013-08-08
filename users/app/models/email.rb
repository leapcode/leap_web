class Email < String
  include ActiveModel::Validations

  validates :email,
    :format => {
      :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/,
      :message => "needs to be a valid email address"
    }

  def to_partial_path
    "emails/email"
  end

  def to_param
    to_s
  end

  def email
    self
  end

end
