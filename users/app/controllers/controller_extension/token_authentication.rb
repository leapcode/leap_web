module ControllerExtension::TokenAuthentication
  extend ActiveSupport::Concern

  def token_authenticate
    token = nil
    authenticate_or_request_with_http_token do |token, options|
      token = Token.find(token)
    end
    User.find(token.user_id) if token
  end
end

