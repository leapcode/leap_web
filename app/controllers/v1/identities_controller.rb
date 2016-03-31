module V1
  class IdentitiesController < ApiController
    before_filter :token_authenticate
    before_filter :require_monitor

    def show
      @identity = Identity.find_by_address(params[:id])
      if @identity
        respond_with @identity
      else
        render_not_found
      end
    end

  end
end
