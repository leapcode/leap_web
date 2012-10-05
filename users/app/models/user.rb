class User < CouchRest::Model::Base

  property :login, String, :accessible => true
  property :email, String, :accessible => true
  property :password_verifier, String, :accessible => true
  property :password_salt, String, :accessible => true

  validates :login, :password_salt, :password_verifier, :presence => true
  validates :login, :uniqueness => true

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
        :password_verifier => "1234",
        :password_salt => "4321" }
    end

  end

  def to_param
    self.login
  end

  def to_json(options={})
    super(options.merge(:only => ['login', 'password_salt']))
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

  def self.current
    Thread.current[:user]
  end
  def self.current=(user)
    Thread.current[:user] = user
  end

  def self.current_test
    User.first
  end

end
