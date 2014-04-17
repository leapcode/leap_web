# The nil object for the user class
class UnauthenticatedUser < Object

  def effective_service_level
    ServiceLevel.new id: APP_CONFIG[:unauthenticated_service_level]
  end

  def is_admin?
    false
  end

  def id
    nil
  end

  def email_address
    nil
  end

  def login
    nil
  end

  def messages
    []
  end
end
