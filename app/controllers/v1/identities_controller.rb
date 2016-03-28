module V1
  class IdentitiesController < ApiController
    before_filter :token_authenticate
    before_filter :require_monitor

    def show
      @identity = Identity.find_by_address(params[:id])
      respond_with @identity
    end

  end
end
