module ControllerExtension::Authentication
  extend ActiveSupport::Concern

  private

  included do
    helper_method :current_user, :logged_in?, :admin?
  end

  def authentication_errors
    return unless attempted_login?
    errors = get_warden_errors
    #default response to get_warden_errors is not an enumerable, so won't work if default is used
    errors.inject({}) do |translated,err|
      translated[err.first] = I18n.t(err.last)
      translated
    end
  end

  def get_warden_errors
    if strategy = warden.winning_strategy
      strategy.message
    else
      { login: :all_strategies_failed }
    end
  end

  def attempted_login?
    request.env['warden.options'] &&
      request.env['warden.options'][:attempted_path]
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
