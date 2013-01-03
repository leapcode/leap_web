class User < CouchRest::Model::Base

  use_database :users

  property :login, String, :accessible => true
  property :password_verifier, String, :accessible => true
  property :password_salt, String, :accessible => true

  property :email, String, :accessible => true
  property :email_forward, String, :accessible => true
  property :email_aliases, [LocalEmail]

  validates :login, :password_salt, :password_verifier,
    :presence => true

  validates :login,
    :uniqueness => true,
    :if => :serverside?

  validates :login,
    :format => { :with => /\A[A-Za-z\d_]+\z/,
      :message => "Only letters, digits and _ allowed" }

  validates :password_salt, :password_verifier,
    :format => { :with => /\A[\dA-Fa-f]+\z/, :message => "Only hex numbers allowed" }

  validates :password, :presence => true,
    :confirmation => true,
    :format => { :with => /.{8}.*/, :message => "needs to be at least 8 characters long" }

  # TODO: write a proper email validator to be used in the different places
  validates :email,
    :format => { :with => /\A(([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,}))?\Z/, :message => "needs to be a valid email address"}

  validates :email,
    :format => { :with => /\A(.+@#{APP_CONFIG[:domain]})?\Z/,
      :message => "needs to end in @#{APP_CONFIG[:domain]}"}

  validate :email_unique_on_server

  validates :email_forward,
    :format => { :with => /\A(([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,}))?\Z/, :message => "needs to be a valid email address"}

  validate :email_differs_from_email_aliases

  timestamps!

  design do
    load_views(Rails.root.join('users', 'app', 'designs', 'user'))
    view :by_login
    view :by_created_at
    view :by_email
  end

  class << self
    alias_method :find_by_param, :find

    # valid set of attributes for testing
    def valid_attributes_hash
      { :login => "me",
        :password_verifier => "1234ABCD",
        :password_salt => "4321AB" }
    end

  end

  alias_method :to_param, :id

  def to_json(options={})
    {
      :login => login,
      :ok => valid?
    }.to_json(options)
  end

  def initialize_auth(aa)
    return SRP::Session.new(self, aa)
  end

  def salt
    password_salt.hex
  end

  def verifier
    password_verifier.hex
  end

  def username
    login
  end

  # Since we are storing admins by login, we cannot allow admins to change their login.
  def is_admin?
    APP_CONFIG['admins'].include? self.login
  end

  # this currently only adds the first email address submitted.
  # All the ui needs for now.
  def email_aliases_attributes=(attrs)
    email_aliases.build(attrs.values.first) if attrs
  end

  protected

  ##
  #  Validation Functions
  ##

  def email_differs_from_email_aliases
    # If this has not changed but the email aliases let's not mark this invalid.
    return if email_aliases.any? and email_aliases.last.errors.any?
    if email_aliases.map(&:email).include?(email)
      errors.add(:email, "may not be the same as an alias")
    end
  end

  def email_unique_on_server
    return unless email
    has_email = User.find_by_email_or_alias(email)
    if has_email && has_email != self.base_doc
      errors.add :email, "has already been taken"
    end
  end

  def password
    password_verifier
  end

  # used as a condition for validations that are server side only
  def serverside?
    true
  end
end
