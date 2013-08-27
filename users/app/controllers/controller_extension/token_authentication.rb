module ControllerExtension::TokenAuthentication
  extend ActiveSupport::Concern

  def token_authenticate
    authenticate_with_http_token do |token_id, options|
      @token = Token.find(token_id)
    end
    User.find_by_param(@token.user_id) if @token
  end

  def logout
    super
    clear_token
  end

  def clear_token
    authenticate_with_http_token do |token_id, options|
      @token = Token.find(token_id)
      @token.destroy if @token
    end
  end
end

