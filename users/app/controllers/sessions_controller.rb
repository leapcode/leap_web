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

  #
  # this is a bad hack, but user_overview_url(user) is not available
  # also, this doesn't work because the redirect happens as a PUT. no idea why.
  #
  #Warden::Manager.after_authentication do |user, auth, opts|
  #  response = Rack::Response.new
  #  response.redirect "/users/#{user.id}/overview"
  # throw :warden, response.finish
  #end

end
