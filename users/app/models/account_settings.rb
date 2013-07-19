class AccountSettings

  def initialize(user)
    @user = user
  end

  def update(attrs)
    if attrs[:password_verifier].present?
      update_login(attrs[:login])
      @user.update_attributes attrs.slice(:password_verifier, :password_salt)
    end
    # TODO: move into identity controller
    update_pgp_key(attrs[:public_key]) if attrs.has_key? :public_key
    @user.save && save_identities
  end

  protected

  def update_login(login, verifier)
    return unless login.present?
    @old_identity = Identity.for(@user)
    @user.login = login
    @new_identity = Identity.for(@user) # based on the new login
    @old_identity.destination = @user.email_address # alias old -> new
  end

  def update_pgp_key(key)
    @new_identity ||= Identity.for(@user)
    @new_identity.set_key(:pgp, key)
  end

  def save_identities
    @new_identity.try(:save) && @old_identity.try(:save)
  end

end
