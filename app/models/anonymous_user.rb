# The nil object for the user class
class AnonymousUser < Object

  def effective_service_level
    AnonymousServiceLevel.new
  end

  def is_admin?
    false
  end

  def id
    nil
  end
  
  def has_payment_info?
    false
  end

  def email
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

  def is_anonymous?
    true
  end

end
