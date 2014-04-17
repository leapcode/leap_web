#
# common base class for all user related controllers
#

class UsersBaseController < ApplicationController

  protected

  def fetch_user
    @user = User.find(params[:user_id] || params[:id])
    if !@user && admin?
      redirect_to users_url, :alert => t(:no_such_thing, :thing => 'user')
    elsif !admin? && @user != current_user
      access_denied
    end
  end

end
