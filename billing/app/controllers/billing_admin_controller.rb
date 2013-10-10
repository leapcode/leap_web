class BillingAdminController < BillingBaseController
  before_filter :authorize_admin

  def show
    @past_due_atleast_90_days = Braintree::Subscription.search do |search|
      search.days_past_due >= 90
    end

    @all_past_due = Braintree::Subscription.search do |search|
      search.status.is Braintree::Subscription::Status::PastDue
      #cannot search by balance.
    end
  end

end
