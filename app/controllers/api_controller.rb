class ApiController < ApplicationController

  skip_before_filter :verify_authenticity_token

  protected

  def require_login
    require_token
  end

  def anonymous_access_allowed?
    APP_CONFIG[:allow_anonymous_certs]
  end

end

