class User < CouchRest::Model::Base

  property :login, String, :accessible => true
  property :email, String, :accessible => true
  property :password_verifier, String, :accessible => true
  property :password_salt, String, :accessible => true

  validates :login, :password_salt, :password_verifier,
    :presence => true

  validates :login,
    :uniqueness => true

  validates :login,
    :format => { :with => /\A[A-Za-z\d_]+\z/,
      :message => "Only letters, digits and _ allowed" }

  validates :password_salt, :password_verifier,
    :format => { :with => /\A[\dA-Fa-f]+\z/,
      :message => "Only hex numbers allowed" }

  timestamps!

  design do
    view :by_login
  end

  class << self
    def find_by_param(login)
      return find_by_login(login) || raise(RECORD_NOT_FOUND)
    end

    # valid set of attributes for testing
    def valid_attributes_hash
      { :login => "me",
        :password_verifier => "1234ABC",
        :password_salt => "4321AB" }
    end

  end

  def to_param
    self.login
  end

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

end
