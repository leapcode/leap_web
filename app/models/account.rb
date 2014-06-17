#
# The Account model takes care of the livecycle of a user.
# It composes a User record and it's identity records.
# It also allows for other engines to hook into the livecycle by
# monkeypatching the create, update and destroy methods.
# There's an ActiveSupport load_hook at the end of this file to
# make this more easy.
#
class Account

  attr_reader :user

  def initialize(user = nil)
    @user = user
  end

  # Returns the user record so it can be used in views.
  def self.create(attrs)
    @user = User.create(attrs)
    if @user.persisted?
      @identity = @user.identity
      @identity.user_id = @user.id
      @identity.save
      @identity.errors.each do |attr, msg|
        @user.errors.add(attr, msg)
      end
    end
  rescue StandardError => ex
    @user.errors.add(:base, ex.to_s)
  ensure
    if @user.persisted? && (@identity.nil? || !@identity.persisted?)
      @user.destroy
    end
    return @user
  end

  def update(attrs)
    if attrs[:password_verifier].present?
      update_login(attrs[:login])
      @user.update_attributes attrs.slice(:password_verifier, :password_salt)
    end
    # TODO: move into identity controller
    key = update_pgp_key(attrs[:public_key])
    @user.errors.set :public_key, key.errors.full_messages
    @user.save && save_identities
    @user.refresh_identity
  end

  def destroy
    return unless @user
    Identity.disable_all_for(@user)
    @user.destroy
  end

  protected

  def update_login(login)
    return unless login.present?
    @old_identity = Identity.for(@user)
    @user.login = login
    @new_identity = Identity.for(@user) # based on the new login
    @old_identity.destination = @user.email_address # alias old -> new
  end

  def update_pgp_key(key)
    PgpKey.new(key).tap do |key|
      if key.present? && key.valid?
        @new_identity ||= Identity.for(@user)
        @new_identity.set_key(:pgp, key)
      end
    end
  end

  def save_identities
    @new_identity.try(:save) && @old_identity.try(:save)
  end

  # You can hook into the account lifecycle from different engines using
  #   ActiveSupport.on_load(:account) do ...
  ActiveSupport.run_load_hooks(:account, self)
end
