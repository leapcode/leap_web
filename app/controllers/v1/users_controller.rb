module V1
  class UsersController < ApiController
    include ControllerExtension::FetchUser

    before_filter :fetch_user, :only => [:update, :destroy]
    before_filter :require_admin, :only => [:index]
    before_filter :require_login, :only => [:index, :update, :destroy]
    before_filter :require_registration_allowed, only: :create

    respond_to :json

    # used for autocomplete for admins in the web ui
    def index
      if params[:query]
        @users = User.login_starts_with(params[:query])
        respond_with @users.map(&:login).sort
      else
        render :json => {'error' => 'query required', 'status' => :unprocessable_entity}
      end
    end

    def create
      @user = Account.create(params[:user])
      respond_with @user # return ID instead?
    end

    def update
      @user.account.update params[:user]
      respond_with @user
    end

    def destroy
      @user.account.destroy(params[:identities] == "destroy")
      if @user == current_user
        logout
      end
      render :json => {'success' => 'user deleted'}
    end

    protected

    def require_registration_allowed
      unless APP_CONFIG[:allow_registration]
        head :forbidden
      end
    end
  end
end
