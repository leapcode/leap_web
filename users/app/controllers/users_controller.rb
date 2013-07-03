#
# This is an HTML-only controller. For the JSON-only controller, see v1/users_controller.rb
#

class UsersController < UsersBaseController

  before_filter :authorize, :only => [:show, :edit, :update, :destroy]
  before_filter :fetch_user, :only => [:show, :edit, :update, :destroy]
  before_filter :authorize_admin, :only => [:index]

  respond_to :html

  def index
    if params[:query]
      @users = User.by_login.startkey(params[:query]).endkey(params[:query].succ)
    else
      @users = User.by_created_at.descending
    end
    @users = @users.limit(APP_CONFIG[:pagination_size])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.create(params[:user])
    respond_with @user
  end

  def show
  end

  def edit
  end

  def destroy
    @user.destroy
    redirect_to admin? ? users_path : login_path
  end

end
