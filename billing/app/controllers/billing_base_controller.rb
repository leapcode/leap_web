class BillingBaseController < ApplicationController
  before_filter :assign_user

  # required for navigation to work.
  def assign_user
    @user = current_user
  end

end
