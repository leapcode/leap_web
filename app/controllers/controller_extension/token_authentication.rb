module ControllerExtension::TokenAuthentication
  extend ActiveSupport::Concern

  def token
    @token ||= authenticate_with_http_token do |token_id, options|
      Token.find(token_id)
    end
  end

  def token_authenticate
    @token_authenticated ||= token.authenticate if token
  end

  def require_token
    access_denied unless token_authenticate
  end

  def logout
    super
    clear_token
  end

  def clear_token
    token.destroy if token
  end
end

