#
# fetch the user taking into account permissions.
# While normal users can only change settings for themselves
# admins can change things for all users.
#
module ControllerExtension::FetchUser
  extend ActiveSupport::Concern

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
