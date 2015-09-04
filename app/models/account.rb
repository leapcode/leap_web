#
# The Account model takes care of the lifecycle of a user.
# It composes a User record and it's identity records.
# It also allows for other engines to hook into the lifecycle by
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
    identity = nil
    user = nil
    user = User.new(attrs)
    user.save

    if !user.tmp? && user.persisted?
      identity = user.identity
      identity.user_id = user.id
      identity.save
      identity.errors.each do |attr, msg|
        user.errors.add(attr, msg)
      end
      user_invite_code = InviteCode.find_by_invite_code user.invite_code
      user_invite_code.invite_count += 1
      user_invite_code.save
    end
  rescue StandardError => ex
    user.errors.add(:base, ex.to_s) if user
  ensure
    if creation_problem?(user, identity)
      user.destroy     if user     && user.persisted?
      identity.destroy if identity && identity.persisted?
    end
    return user
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

  def destroy(destroy_identity=false)
    return unless @user
    if !user.tmp?
      if destroy_identity == false
        Identity.disable_all_for(@user)
      else
        Identity.destroy_all_for(@user)
      end
    end
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

  def self.creation_problem?(user, identity)
    return true if user.nil? || !user.persisted? || user.errors.any?
    if !user.tmp?
      return true if identity.nil? || !identity.persisted? || identity.errors.any?
    end
    return false
  end

  # You can hook into the account lifecycle from different engines using
  #   ActiveSupport.on_load(:account) do ...
  ActiveSupport.run_load_hooks(:account, self)
end
