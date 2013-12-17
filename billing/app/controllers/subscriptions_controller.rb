class SubscriptionsController < BillingBaseController
  before_filter :authorize
  before_filter :fetch_subscription, :only => [:show, :destroy]
  before_filter :confirm_cancel_subscription, :only => [:destroy]
  before_filter :confirm_self_or_admin, :only => [:index]
  before_filter :confirm_no_pending_active_pastdue_subscription, :only => [:new, :create]
  # for now, admins cannot create or destroy subscriptions for others:
  before_filter :confirm_self, :only => [:new, :create]

  def new
    # don't show link to subscribe if they are already subscribed?
    credit_card = @customer.default_credit_card #safe to assume default?
    @payment_method_token = credit_card.token
    @plans = Braintree::Plan.all
  end

  # show has no content, so not needed at this point.

  def create
    @result = Braintree::Subscription.create( :payment_method_token => params[:payment_method_token], :plan_id => params[:plan_id] )
    #if you want to test pastdue, can add :price => '2001', :trial_period => true,:trial_duration => 1,:trial_duration_unit => "day" and then wait a day
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
    @credit_card = Braintree::CreditCard.find @subscription.payment_method_token
    @subscription_customer_id = @credit_card.customer_id
    current_user_customer = Customer.find_by_user_id(current_user.id)
    access_denied unless admin? or (current_user_customer and current_user_customer.braintree_customer_id == @subscription_customer_id)

  end

  def confirm_cancel_subscription
    access_denied unless view_context.allow_cancel_subscription(@subscription)
  end

  def confirm_no_pending_active_pastdue_subscription
    @customer = Customer.find_by_user_id(@user.id)
    if subscription = @customer.subscriptions # will return pending, active or pastdue subscription, if it exists
      redirect_to user_subscription_path(@user, subscription.id), :notice => 'You already have a subscription'
    end
  end

  def confirm_self
    @user == current_user
  end

  def confirm_self_or_admin
    access_denied unless confirm_self or admin?
  end

end
