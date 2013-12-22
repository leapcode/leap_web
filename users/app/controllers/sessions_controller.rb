class SessionsController < ApplicationController

  def new
    redirect_to home_url if logged_in?
    @session = Session.new
    if authentication_errors
      @errors = authentication_errors
      render :status => 422
    end
  end

  def destroy
    logout
    redirect_to home_url
  end

  #
  # this is a bad hack, but user_url(user) is not available
  # also, this doesn't work because the redirect happens as a PUT. no idea why.
  #
  #Warden::Manager.after_authentication do |user, auth, opts|
  #  response = Rack::Response.new
  #  response.redirect "/users/#{user.id}"
  # throw :warden, response.finish
  #end

end
