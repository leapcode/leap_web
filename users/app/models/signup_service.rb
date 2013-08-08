class SignupService

  def register(attrs)
    User.create(attrs).tap do |user|
      Identity.create_for user
    end
  end

end
