class SessionsController < ApplicationController

  skip_before_filter :verify_authenticity_token

  def new
    @errors = authentication_error
  end

  def create
    authenticate!
  end

  def update
    authenticate!
  end

  def destroy
    logout
    redirect_to root_path
  end
end
