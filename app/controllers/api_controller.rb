class ApiController < ApplicationController

  skip_before_filter :verify_authenticity_token
  respond_to :json

  def require_login
    require_token
  end

end

