module Email
  extend ActiveSupport::Concern

  included do
    validates :email,
      :format => {
        :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/,
        :message => "needs to be a valid email address"
      }
  end

  def initialize(attributes = nil, &block)
    attributes = {:email => attributes} if attributes.is_a? String
    super(attributes, &block)
  end

  def to_s
    email
  end

  def ==(other)
    other.is_a?(Email) ? self.email == other.email : self.email == other
  end

  def to_partial_path
    "emails/email"
  end

  def to_param
    email
  end

end
