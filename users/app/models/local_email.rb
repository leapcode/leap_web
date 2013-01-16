class LocalEmail

  property :username, String

  validates :username,
    :format => { :with => /\A([^@\s]+)(@.*)?\Z/, :message => "needs to be a valid login or email address"}

  validate :unique_on_server
  validate :unique_alias_for_user
  validate :differs_from_main_email
  before_validation :strip_domain_if_needed
  validates :username,
    :presence => true,
    :format => { :with => /[^@]*(@#{APP_CONFIG[:domain]})?\Z/i,
      :message => "needs to end in @#{APP_CONFIG[:domain]}"}
  validates :casted_by, :presence => true

  def initialize(attributes = nil, &block)
    attributes = {:username => attributes} if attributes.is_a? String
    super(attributes, &block)
  end

  def to_s
    email
  end

  def ==(other)
    other.is_a?(String) ? self.email == other : super
  end

  def to_param
    email
  end

  def to_partial_path
    "emails/email"
  end

  protected

  def unique_on_server
    has_email = User.find_by_login_or_alias(username)
    if has_email && has_email != self.base_doc
      errors.add :username, "has already been taken"
    end
  end

  def unique_alias_for_user
    aliases = self.casted_by.email_aliases
    if aliases.select{|a|a.username == self.username}.count > 1
      errors.add :username, "is already your alias"
    end
  end

  def differs_from_main_email
    # If this has not changed but the email let's mark the email invalid instead.
    return if self.persisted?
    user = self.casted_by
    if user.login == self.username
      errors.add :username, "may not be the same as your email address"
    end
  end

  def strip_domain_if_needed
    self.username.gsub /@#{APP_CONFIG[:domain]}/i, ''
  end

end
