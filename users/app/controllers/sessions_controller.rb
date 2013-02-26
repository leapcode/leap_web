class SessionsController < ApplicationController

  def new
    @session = Session.new
    if authentication_errors
      @errors = authentication_errors
      render :status => 422
    end
  end

  def create
    logout if logged_in?
    authenticate!
  end

  def update
    authenticate!
    render :json => session.delete(:handshake)
  end

  def destroy
    logout
    redirect_to root_path
  end
end
