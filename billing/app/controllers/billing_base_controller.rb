class BillingBaseController < ApplicationController
  before_filter :assign_user

  helper 'billing'

  # required for navigation to work.
  def assign_user
    @user = current_user
  end

end
