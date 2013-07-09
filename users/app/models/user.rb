class User < CouchRest::Model::Base

  use_database :users

  property :login, String, :accessible => true
  property :password_verifier, String, :accessible => true
  property :password_salt, String, :accessible => true

  property :email_forward, String, :accessible => true
  property :email_aliases, [LocalEmail]

  property :public_key, :accessible => true

  property :enabled, TrueClass, :default => true

  validates :login, :password_salt, :password_verifier,
    :presence => true

  validates :login,
    :uniqueness => true,
    :if => :serverside?

  # Have multiple regular expression validations so we can get specific error messages:
  validates :login,
    :format => { :with => /\A.{2,}\z/,
      :message => "Login must have at least two characters"}
  validates :login,
    :format => { :with => /\A[a-z\d_\.-]+\z/,
      :message => "Only lowercase letters, digits, . - and _ allowed."}
  validates :login,
    :format => { :with => /\A[a-z].*\z/,
      :message => "Login must begin with a lowercase letter"}
  validates :login,
    :format => { :with => /\A.*[a-z\d]\z/,
      :message => "Login must end with a letter or digit"}

  validate :login_is_unique_alias

  validates :password_salt, :password_verifier,
    :format => { :with => /\A[\dA-Fa-f]+\z/, :message => "Only hex numbers allowed" }

  validates :password, :presence => true,
    :confirmation => true,
    :format => { :with => /.{8}.*/, :message => "needs to be at least 8 characters long" }

  validates :email_forward,
    :allow_blank => true,
    :format => { :with => /\A(([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,}))?\Z/, :message => "needs to be a valid email address"}

  timestamps!

  design do
    own_path = Pathname.new(File.dirname(__FILE__))
    load_views(own_path.join('..', 'designs', 'user'))
    view :by_login
    view :by_created_at
    view :pgp_key_by_handle,
      map: <<-EOJS
      function(doc) {
        if (doc.type != 'User') {
          return;
        }
        emit(doc.login, doc.public_key);
        doc.email_aliases.forEach(function(alias){
          emit(alias.username, doc.public_key);
        });
      }
    EOJS

  end # end of design

  class << self
    alias_method :find_by_param, :find
  end

  def to_param
    self.id
  end

  def to_json(options={})
    {
      :login => login,
      :ok => valid?
    }.to_json(options)
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

  def email_address
    LocalEmail.new(login)
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

  def most_recent_tickets(count=3)
    Ticket.for_user(self).limit(count).all #defaults to having most recent updated first
  end

  protected

  ##
  #  Validation Functions
  ##

  def login_is_unique_alias
    has_alias = User.find_by_login_or_alias(username)
    return if has_alias.nil?
    if has_alias != self
      errors.add(:login, "has already been taken")
    elsif has_alias.login != self.login
      errors.add(:login, "may not be the same as one of your aliases")
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
