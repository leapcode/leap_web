module ControllerExtension::TokenAuthentication
  extend ActiveSupport::Concern

  protected

  def token
    @token ||= authenticate_with_http_token do |token, options|
      Token.find_by_token(token) || ApiToken.find_by_token(token, request.headers['REMOTE_ADDR'])
    end
  end

  def token_authenticate
    @token_authenticated ||= token.authenticate if token
  end

  def require_token
    login_required unless token_authenticate
  end

  def logout
    super
    clear_token
  end

  def clear_token
    token.destroy if token
  end
end

