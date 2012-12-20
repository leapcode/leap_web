class LocalEmail < Email

  validate :unique_on_server
  validate :unique_alias_for_user
  validate :differs_from_main_email
  before_validation :add_domain_if_needed
  validates :email,
    :format => { :with => /@#{APP_CONFIG[:domain]}\Z/,
      :message => "needs to end in @#{APP_CONFIG[:domain]}"}
  validates :casted_by, :presence => true

  def to_partial_path
    "emails/email"
  end

  protected

  def unique_on_server
     has_email = User.find_by_email_or_alias(email)
     if has_email && has_email != self.base_doc
      errors.add :email, "has already been taken"
    end
  end

  def unique_alias_for_user
    aliases = self.casted_by.email_aliases
    if aliases.select{|a|a.email == self.email}.count > 1
      errors.add :email, "is already your alias"
    end
  end

  def differs_from_main_email
    user = self.casted_by
    if user.email == self.email
      errors.add :email, "may not be the same as your email address"
    end
  end

  def add_domain_if_needed
    self.email = self.email + "@" + APP_CONFIG[:domain] unless self.email.include?("@")
  end

end
