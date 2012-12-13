class LocalEmail < Email

  validate :unique_on_server

  def unique_on_server
     has_email = User.find_by_email_or_alias(email)
     if has_email && has_email != self.base_doc
      errors.add(:email, "has already been taken")
    end
  end
end
