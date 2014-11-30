class ApiController < ApplicationController

  skip_before_filter :verify_authenticity_token
  respond_to :json

  protected

  #
  # For now, we are going to allow cookie authentication if there is
  # no "Authorization" header in the request. This is to keep backward
  # compatibility with older clients. In the future, this should be
  # disabled.
  #
  def require_login
    if ActionController::HttpAuthentication::Token.token_and_options(request)
      require_token
    else
      super
    end
  end

  def anonymous_access_allowed?
    APP_CONFIG[:allow_anonymous_certs]
  end

end

