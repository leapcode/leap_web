class V1::ServicesController < ApplicationController

  respond_to :json

  def show
    respond_with current_user.effective_service_level
  end
end
