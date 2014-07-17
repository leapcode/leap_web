#
# This is an HTML-only controller. For the JSON-only controller, see v1/users_controller.rb
#

class UsersController < ApplicationController
  include ControllerExtension::FetchUser

  before_filter :require_login, :except => [:new]
  before_filter :redirect_if_logged_in, :only => [:new]
  before_filter :require_admin, :only => [:index, :deactivate, :enable]
  before_filter :fetch_user, :only => [:show, :edit, :update, :destroy, :deactivate, :enable]
  before_filter :require_registration_allowed, only: :new

  respond_to :html

  def index
    if params[:query].present?
      if @user = User.find_by_login(params[:query])
        redirect_to @user
        return
      else
        @users = User.login_starts_with(params[:query])
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

  ## added so updating service level works, but not sure we will actually want this. also not sure that this is place to prevent user from updating own effective service level, but here as placeholder:
  def update
    @user.update_attributes(params[:user]) unless (!admin? and params[:user][:effective_service_level])
    respond_with @user
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
    @user.account.destroy
    flash[:notice] = I18n.t(:account_destroyed)
    # admins can destroy other users
    if @user != current_user
      redirect_to users_url
    else
      # let's remove the invalid session
      logout
      redirect_to bye_url
    end
  end

  protected

  def require_registration_allowed
    unless APP_CONFIG[:allow_registration]
      redirect_to home_path
    end
  end

end
