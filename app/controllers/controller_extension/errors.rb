module ControllerExtension::Errors
  extend ActiveSupport::Concern

  protected

  def access_denied
    render_error :not_authorized, :forbidden, home_url
  end

  def login_required
    # Warden will intercept the 401 response and call
    # SessionController#unauthenticated instead.
    render_error :not_authorized_login, :unauthorized, login_url
  end

  def not_found(msg=nil, url=nil)
    render_error(msg || :not_found, :not_found, url || home_url)
  end

  private

  def render_error(message, status=nil, redirect=nil)
    error = message
    message = t(message) if message.is_a?(Symbol)
    respond_to do |format|
      format.html do
        redirect_to redirect, alert: message
      end
      format.json do
        status ||= :unprocessable_entity
        render json: {error: error, message: message}, status: status
      end
    end
  end
end
