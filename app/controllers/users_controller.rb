#
# This is an HTML-only controller. For the JSON-only controller, see v1/users_controller.rb
#

class UsersController < ApplicationController
  include ControllerExtension::FetchUser

  before_filter :require_login
  before_filter :require_admin, :only => [:index, :deactivate, :enable]
  before_filter :fetch_user, :except => [:index]

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

  def show
  end

  def edit
  end

  def deactivate
    @user.account.disable
    flash[:notice] = I18n.t("actions.user_disabled_message", username: @user.username)
    redirect_to :back
  end

  def enable
    @user.account.enable
    flash[:notice] = I18n.t("actions.user_enabled_message", username: @user.username)
    redirect_to :back
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

  def user_params
    if admin?
      params.require(:user).permit(:effective_service_level)
    else
      params.require(:user).permit(:password, :password_confirmation)
    end
  end
end
