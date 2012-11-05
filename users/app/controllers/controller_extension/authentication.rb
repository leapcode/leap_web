module ControllerExtension::Authentication
  extend ActiveSupport::Concern

  private

  included do
    helper_method :current_user, :logged_in?, :admin?
  end

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def logged_in?
    !!current_user
  end

  def authorize
    access_denied unless logged_in?
  end

  def access_denied
    # TODO: should we redirect to the root_url in either case, and have the root_url include the login screen (and also ability to create unauthenticated tickets) when no user is logged in?
    redirect_to login_url, :alert => "Not authorized" if !logged_in?
    redirect_to root_url, :alert => "Not authorized" if logged_in?
  end

  def admin?
    current_user && current_user.is_admin?
  end

  def authorize_admin
    access_denied unless admin?
  end

end
