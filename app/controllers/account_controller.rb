class AccountController < ApplicationController

  before_filter :require_registration_allowed
  before_filter :redirect_if_logged_in

  def new
    @user = User.new
  end

  protected

  def require_registration_allowed
    unless APP_CONFIG[:allow_registration]
      redirect_to home_path
    end
  end
end
