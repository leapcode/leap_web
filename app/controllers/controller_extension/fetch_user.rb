#
# fetch the user taking into account permissions.
# While normal users can only change settings for themselves
# admins can change things for all users.
#
module ControllerExtension::FetchUser
  extend ActiveSupport::Concern

  protected

  #
  # fetch @user from params, but enforce permissions:
  #
  # * admins may fetch any user
  # * monitors may fetch test users
  # * users may fetch themselves
  #
  # these permissions matter, it is what protects
  # users from being updated or deleted by other users.
  #
  def fetch_user
    @user = User.find(params[:user_id] || params[:id])
    if current_user.is_admin? || current_user.is_monitor?
      if @user.nil?
        not_found(t(:no_such_thing, :thing => 'user'), users_url)
      elsif current_user.is_monitor?
        access_denied unless @user.is_test?
      end
    elsif @user != current_user
      access_denied
    end
  end

end
