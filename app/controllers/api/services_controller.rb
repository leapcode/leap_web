class Api::ServicesController < ApiController

  before_filter :require_login, :unless => :anonymous_access_allowed?

  def show
    respond_with current_user.effective_service_level
  end
end
