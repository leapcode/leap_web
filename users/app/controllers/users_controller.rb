#
# This is an HTML-only controller. For the JSON-only controller, see v1/users_controller.rb
#

class UsersController < UsersBaseController

  before_filter :authorize, :only => [:show, :edit, :update, :destroy]
  before_filter :fetch_user, :only => [:show, :edit, :update, :destroy]
  #before_filter :authorize_self, :only => [:update]
  before_filter :authorize_admin, :only => [:index]

  respond_to :json

  def index
    if params[:query]
      @users = User.by_login.startkey(params[:query]).endkey(params[:query].succ)
    else
      @users = User.by_created_at.descending
    end
    @users = @users.limit(APP_CONFIG[:pagination_size])
    #respond_with @users.map(&:login).sort
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

  #
  # The API user update is used instead. Maybe someday we will have something for which this makes sense.
  #
  #def update
  #  @user.update_attributes(params[:user])
  #  respond_with @user
  #end

  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to(admin? ? users_path : root_path) }
      format.json { head :no_content }
    end
  end

  protected

  #def authorize_self
  #  # have already checked that authorized
  #  access_denied unless (@user == current_user)
  #end

end
