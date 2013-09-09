class BillingBaseController < ApplicationController
  before_filter :assign_user

  helper 'billing'

  # required for navigation to work.
  def assign_user
    if params[:user_id]
      @user = User.find(params[:user_id])
    elsif params[:action] == "confirm"# confirms will come back with different ID set, so check for this first
      # This is only for cases where an admin cannot apply action for customer, but should be all confirms
      @user = current_user
    elsif params[:id]
      @user = User.find(params[:id])
    else
      # TODO
      # hacky, what are cases where @user hasn't yet been set? certainly some cases with subscriptions and payments
      @user = current_user
    end
  end

end
