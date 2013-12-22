module ControllerExtension::Authentication
  extend ActiveSupport::Concern

  private

  included do
    helper_method :current_user, :logged_in?, :admin?
  end

  def current_user
    @current_user ||= token_authenticate || warden.user
  end

  def logged_in?
    !!current_user
  end

  def authorize
    access_denied unless logged_in?
  end

  def access_denied
    respond_to do |format|
      format.html do
        if logged_in?
          redirect_to home_url, :alert => t(:not_authorized)
        else
          redirect_to login_url, :alert => t(:not_authorized_login)
        end
      end
      format.json do
        render :json => {'error' => t(:not_authorized)}, status: :unprocessable_entity
      end
    end
  end

  def admin?
    current_user && current_user.is_admin?
  end

  def authorize_admin
    access_denied unless admin?
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
end
