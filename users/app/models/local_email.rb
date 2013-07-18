class LocalEmail < Email

=begin
  validate :unique_on_server
  validate :unique_alias_for_user
  validate :differs_from_login
=end


  def email=(value)
    return if value.blank?
    self.username = value
    strip_domain_if_needed
  end

  def to_key
    [username]
  end

  protected

  def unique_on_server
    has_email = User.find_by_login_or_alias(username)
    if has_email && has_email != self.casted_by
      errors.add :username, "has already been taken"
    end
  end

  def unique_alias_for_user
    aliases = self.casted_by.email_aliases
    if aliases.select{|a|a.username == self.username}.count > 1
      errors.add :username, "is already your alias"
    end
  end

  def differs_from_login
    # If this has not changed but the email let's mark the email invalid instead.
    return if self.persisted?
    user = self.casted_by
    if user.login == self.username
      errors.add :username, "may not be the same as your email address"
    end
  end

  def strip_domain_if_needed
    self.username.gsub! /@#{APP_CONFIG[:domain]}/i, ''
  end

end
