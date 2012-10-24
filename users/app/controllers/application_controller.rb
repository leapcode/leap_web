class ApplicationController < ActionController::Base
  protect_from_forgery

  protected

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
  helper_method :current_user

  def logged_in?
    !!current_user
  end
  helper_method :logged_in?

  def authorize
    access_denied unless logged_in?
  end

  def admin?
    current_user && current_user.is_admin?
  end
  helper_method :admin?

  def authorize_admin
    access_denied unless admin?
  end

  def access_denied
    redirect_to login_url, :alert => "Not authorized"
  end
end
