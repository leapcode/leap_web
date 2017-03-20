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

  #
  # Creates a new user, with matching identity record.
  #
  # Returns the user record so it can be used in views.
  #
  # options:
  #
  #  :invite_required -- if 'false', will overrides app-wide
  #                      configuration by same name.
  #
  def self.create(attrs, options={})
    identity = nil
    user = nil
    user = User.new(attrs)
    if options[:invite_required] == false
      user.ignore_invites!
    end
    user.save

    # this is not very atomic, but we do the best we can:
    if !user.is_tmp? && user.persisted?
      identity = user.identity
      identity.user_id = user.id
      identity.save
      identity.errors.each do |attr, msg|
        user.errors.add(attr, msg)
      end
      if user.invite_required?
        user_invite_code = InviteCode.find_by_invite_code user.invite_code
        user_invite_code.invite_count += 1
        user_invite_code.save
      end
    end
  rescue VALIDATION_FAILED => ex
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
    if attrs[:recovery_code_verifier].present?
      @user.update_attributes attrs.slice(:recovery_code_verifier, :recovery_code_salt)
    end
    # TODO: move into identity controller
    key = update_pgp_key(attrs[:public_key])
    @user.errors.set :public_key, key.errors.full_messages
    @user.save && save_identities
    @user.refresh_identity
  end

  def destroy(release_handles=false)
    return unless @user
    if !@user.is_tmp?
      @user.identities.each do |id|
        if release_handles == false
          id.orphan!
        else
          id.destroy
        end
      end
    end
    @user.destroy
  end

  # when a user is disable, all their data and associations remain
  # in place, but the user should not be able to send email or
  # create new authentication certificates.
  def disable
    if @user && !@user.is_tmp?
      @user.enabled = false
      @user.save
      @user.identities.each do |id|
        id.disable!
      end
    end
  end

  def enable
    @user.enabled = true
    @user.save
    @user.identities.each do |id|
      id.enable!
    end
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
    if !user.is_tmp?
      return true if identity.nil? || !identity.persisted? || identity.errors.any?
    end
    return false
  end

  # You can hook into the account lifecycle from different engines using
  #   ActiveSupport.on_load(:account) do ...
  ActiveSupport.run_load_hooks(:account, self)
end
