module ControllerExtension::Authentication
  extend ActiveSupport::Concern

  private

  included do
    helper_method :current_user, :logged_in?, :admin?
  end

  def current_user
    @current_user ||= token_authenticate || warden.user || anonymous
  end

  def logged_in?
    current_user.is_a? User
  end

  def require_login
    login_required unless logged_in?
  end

  # some actions only make sense if you are not logged in yet.
  # (login, signup). If a user tries to perform these they will
  # be redirected to their dashboard.
  def redirect_if_logged_in
    redirect_to home_url if logged_in?
  end

  def admin?
    current_user.is_admin?
  end

  def require_admin
    access_denied unless admin?
  end

  def require_monitor
    unless current_user.is_monitor? || current_user.is_admin?
      access_denied
    end
  end

  def authentication_errors
    return unless attempted_login?
    errors = get_warden_errors
    errors.inject({}) do |translated,err|
      translated[err.first] = I18n.t(err.last)
      translated
    end
  end

  def get_warden_errors
    if strategy = warden.winning_strategy
      message = strategy.message
      # in case we get back the default message to fail!
      message.respond_to?(:inject) ? message : { base: message }
    else
      { login: :all_strategies_failed }
    end
  end

  def attempted_login?
    request.env['warden.options'] &&
      request.env['warden.options'][:attempted_path]
  end

  protected

  def anonymous
    AnonymousUser.new
  end
end
