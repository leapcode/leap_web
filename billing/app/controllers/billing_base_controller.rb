class BillingBaseController < ApplicationController
  before_filter :assign_user

  helper 'billing'

  # required for navigation to work.
  #TODO doesn't work for admins
  def assign_user
    if params[:id]
      @user = User.find_by_param(params[:id])
    else
      @user = current_user #TODO not always correct for admins viewing another user!
    end
  end

end
