module V1
  class UsersController < UsersBaseController

    skip_before_filter :verify_authenticity_token
    before_filter :fetch_user, :only => [:update]
    before_filter :require_admin, :only => [:index]
    before_filter :require_token, :only => [:update]

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

  end
end
