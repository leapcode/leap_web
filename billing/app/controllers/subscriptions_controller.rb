class SubscriptionsController < BillingBaseController
  before_filter :authorize
  before_filter :fetch_subscription, :only => [:show, :destroy]
  before_filter :confirm_no_active_subscription, :only => [:new, :create]

  def new
    # don't show link to subscribe if they are already subscribed?
    credit_card = @customer.default_credit_card #safe to assume default?
    @payment_method_token = credit_card.token
    @plans = Braintree::Plan.all
  end

  # show has no content, so not needed at this point.

  def create
    @result = Braintree::Subscription.create( :payment_method_token => params[:payment_method_token], :plan_id => params[:plan_id] )
  end

  def destroy
    @result = Braintree::Subscription.cancel params[:id]
  end

  def index
    customer = Customer.find_by_user_id(@user.id)
    @subscriptions = customer.subscriptions(nil, false)
  end

  private

  def fetch_subscription
    @subscription = Braintree::Subscription.find params[:id]
    @subscription_customer_id = @subscription.transactions.first.customer_details.id #all of subscriptions transactions should have same customer
    @customer = Customer.find_by_user_id(current_user.id)
    access_denied unless admin? or (@customer and @customer.braintree_customer_id == @subscription_customer_id)
    # TODO: will presumably want to allow admins to view/cancel subscriptions for all users
  end

  def confirm_no_active_subscription
    @customer = Customer.find_by_user_id(current_user.id)
    if subscription = @customer.subscriptions # will return active subscription, if it exists
      redirect_to subscription_path(subscription.id), :notice => 'You already have an active subscription'
    end
  end

end
