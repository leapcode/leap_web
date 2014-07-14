class V1::ServicesController < ApiController

  def show
    respond_with current_user.effective_service_level
  end
end
