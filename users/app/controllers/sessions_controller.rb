class SessionsController < ApplicationController

  skip_before_filter :verify_authenticity_token

  def new
  end

  def create
    env['warden'].authenticate!
  end

  def update
    env['warden'].authenticate!
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path
  end
end
