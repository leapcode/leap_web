class SessionsController < ApplicationController

  skip_before_filter :verify_authenticity_token

  def new
    if warden.winning_strategy
      @errors = warden.winning_strategy.message
    end
  end

  def create
    authenticate!
  end

  def update
    authenticate!
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path
  end
end
