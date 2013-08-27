module ControllerExtension::TokenAuthentication
  extend ActiveSupport::Concern

  def token_authenticate
    authenticate_or_request_with_http_token do |token_id, options|
      @token = Token.find(token_id)
    end
    User.find_by_param(@token.user_id) if @token
  end
end

