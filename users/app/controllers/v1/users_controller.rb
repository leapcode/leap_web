module V1
  class UsersController < UsersBaseController

    skip_before_filter :verify_authenticity_token
    before_filter :fetch_user, :only => [:update]
    before_filter :authorize, :only => [:update]
    before_filter :authorize_admin, :only => [:index]

    respond_to :json

    # used for autocomplete for admins in the web ui
    def index
      if params[:query]
        @users = User.by_login.startkey(params[:query]).endkey(params[:query].succ)
        respond_with @users.map(&:login).sort
      else
        render :json => {'error' => 'query required', 'status' => :unprocessable_entity}
      end
    end

    def create
      @user = signup_service.register(params[:user])
      respond_with @user # return ID instead?
    end

    def update
      account_settings.update params[:user]
      respond_with @user
    end

    protected

    def account_settings
      AccountSettings.new(@user)
    end

    def signup_service
      SignupService.new
    end
  end
end
