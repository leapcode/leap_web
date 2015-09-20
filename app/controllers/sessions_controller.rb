class SessionsController < ApplicationController

  before_filter :redirect_if_logged_in, :only => [:new]

  def new
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
  # Warden will catch all 401s and run this instead:
  #
  def unauthenticated
    login_required
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

  Warden::Manager.after_set_user do |user, auth, opts|
    scope = opts[:scope]
    unless user.enabled?
      auth.logout(scope)
      throw(:warden, scope: scope, reason: "User not active")
    end
  end


end
