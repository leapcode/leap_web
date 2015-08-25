class User < CouchRest::Model::Base
  include LoginFormatValidation

  use_database :users

  property :login, String, :accessible => true
  property :password_verifier, String, :accessible => true
  property :password_salt, String, :accessible => true
  property :contact_email, String, :accessible => true
  property :contact_email_key, String, :accessible => true
  property :invite_code, String, :accessible => true
  property :enabled, TrueClass, :default => true

  # these will be null by default but we shouldn't ever pull them directly, but only via the methods that will return the full ServiceLevel
  property :desired_service_level_code, Integer, :accessible => true
  property :effective_service_level_code, Integer, :accessible => true

  property :one_month_warning_sent, TrueClass

  before_save :update_effective_service_level

  validates :login, :password_salt, :password_verifier,
    :presence => true

  validates :login,
    :uniqueness => true,
    :if => :serverside?

  validate :identity_is_valid

  validates :password_salt, :password_verifier,
    :format => { :with => /\A[\dA-Fa-f]+\z/, :message => "Only hex numbers allowed" }

  validates :password, :presence => true,
    :confirmation => true,
    :format => { :with => /.{8}.*/, :message => "needs to be at least 8 characters long" }

  validates :contact_email, :allow_blank => true,
    :email => true,
    :mx_with_fallback => true


  validates_with InviteCodeValidator


  timestamps!

  design do
    own_path = Pathname.new(File.dirname(__FILE__))
    load_views(own_path.join('..', 'designs', 'user'))
    view :by_login
    view :by_created_at
  end # end of design

  include TemporaryUser # MUST come after designs are defined.

  def self.login_starts_with(query)
    self.by_login.startkey(query).endkey(query + "\ufff0")
  end

  def reload
    @identity = nil
    super
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

  # use this if you want to get a working email address only.
  def email
    if effective_service_level.provides?('email')
      email_address
    end
  end

  # use this if you want the email address associated with a
  # user no matter if the user actually has a local email account
  def email_address
    LocalEmail.new(login)
  end

  # Since we are storing admins by login, we cannot allow admins to change their login.
  def is_admin?
    APP_CONFIG['admins'].include? self.login
  end

  def is_anonymous?
    false
  end

  def most_recent_tickets(count=3)
    Ticket.for_user(self).limit(count).all #defaults to having most recent updated first
  end

  def messages
    #TODO for now this only shows unseen messages. Will we ever want seen ones? Is it necessary to store?
    Message.by_user_ids_to_show.key(self.id)
  end

  # DEPRECATED
  #
  # Please set the key on the identity directly
  # WARNING: This will not be serialized with the user record!
  # It is only a workaround for the key form.
  def public_key=(value)
    identity.set_key(:pgp, value)
  end

  # DEPRECATED
  #
  # Please access identity.keys[:pgp] directly
  def public_key
    identity.keys[:pgp]
  end

  def account
    Account.new(self)
  end

  def identity
    @identity ||= Identity.for(self)
  end

  def refresh_identity
    @identity = Identity.for(self)
  end

  def desired_service_level
    code = self.desired_service_level_code || APP_CONFIG[:default_service_level]
    ServiceLevel.new({id: code})
  end

  def effective_service_level
    code = self.effective_service_level_code || self.desired_service_level.id
    ServiceLevel.new({id: code})
  end


  def self.send_one_month_warnings

    # To determine warnings to send, need to get all users where one_month_warning_sent is not set, and where it was created greater than or equal to 1 month ago.
    # TODO: might want to further limit to enabled accounts, and, based on provider's service level configuration, for particular service levels.
    users_to_warn = User.by_created_at_and_one_month_warning_not_sent.endkey(Time.now-1.month)

    users_to_warn.each do |user|
      # instead of loop could use something like:
      # message.user_ids_to_show = users_to_warn.map(&:id)
      # but would still need to loop through users to store one_month_warning_sent

      if !@message
        # create a message for today's date
        # only want to create once, and only if it will be used.
        @message = Message.new(:text => I18n.t(:payment_one_month_warning, :date_in_one_month => (Time.now+1.month).strftime("%Y-%d-%m")))
      end

      @message.user_ids_to_show << user.id
      user.one_month_warning_sent = true
      user.save
    end
    @message.save if @message

  end

  protected

  ##
  #  Validation Functions
  ##

  def identity_is_valid
    return if identity.valid?
    identity.errors.each do |attribute, error|
      self.errors.add(:login, error)
    end
  end

  def password
    password_verifier
  end

  # used as a condition for validations that are server side only
  def serverside?
    true
  end

  def update_effective_service_level
    # TODO: Is this always the case? Might there be a situation where the admin has set the effective service level and we don't want it changed to match the desired one?
    if self.desired_service_level_code_changed?
      self.effective_service_level_code = self.desired_service_level_code
    end
  end

end
