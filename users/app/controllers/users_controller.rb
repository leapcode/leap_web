#
# This is an HTML-only controller. For the JSON-only controller, see v1/users_controller.rb
#

class UsersController < UsersBaseController

  before_filter :authorize, :only => [:show, :edit, :update, :destroy]
  before_filter :fetch_user, :only => [:show, :edit, :update, :destroy, :deactivate, :enable]
  before_filter :authorize_admin, :only => [:index, :deactivate, :enable]

  respond_to :html

  def index
    if params[:query]
      if @user = User.find_by_login(params[:query])
        redirect_to user_overview_url(@user)
        return
      else
        @users = User.by_login.startkey(params[:query]).endkey(params[:query].succ)
      end
    else
      @users = User.by_created_at.descending
    end
    @users = @users.limit(100)
  end

  def new
    @user = User.new
  end

  def show
  end

  def edit
  end

  def deactivate
    @user.enabled = false
    @user.save
    respond_with @user
  end

  def enable
    @user.enabled = true
    @user.save
    respond_with @user
  end

  def destroy
    @user.destroy
    flash[:notice] = I18n.t(:account_destroyed)
    # admins can destroy other users
    if @user != current_user
      redirect_to users_url
    else
      # let's remove the invalid session
      logout
      redirect_to root_url
    end
  end

end
