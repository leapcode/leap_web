# The nil object for the user class
class UnauthenticatedUser < Object

  # will probably want something here to return service level as  APP_CONFIG[:service_levels][0] but not sure how will be accessing.

  def is_admin?
    false
  end

  def effective_service_level
    ServiceLevel.new id: APP_CONFIG[:unauthenticated_service_level]
  end
end
