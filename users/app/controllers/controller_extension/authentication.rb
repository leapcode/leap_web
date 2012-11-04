module ControllerExtension::Authentication
  extend ActiveSupport::Concern

  private

  included do
    helper_method :current_user, :logged_in?, :admin?
  end

  def authentication_error
    warden.winning_strategy.try(:message)
  end

  def logged_in?
    !!current_user
  end

  def authorize
    access_denied unless logged_in?
  end

  def access_denied
    redirect_to login_url, :alert => "Not authorized"
  end

  def admin?
    current_user && current_user.is_admin?
  end

  def authorize_admin
    access_denied unless admin?
  end

end
