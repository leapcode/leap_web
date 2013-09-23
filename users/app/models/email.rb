class Email < String
  include ActiveModel::Validations

  validates :email,
    :format => {
      :with => /\A([^@\s]+)@((?:[-a-zA-Z0-9]+\.)+[a-zA-Z]{2,})\Z/, #checks format, but allows lowercase
      :message => "needs to be a valid email address"
    }

  validates :email,
    :format => {
      :with => /\A[^A-Z]*\Z/, #forbids uppercase characters
      :message => "letters must be lowercase"
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

  def handle
    self.split('@').first
  end

end
