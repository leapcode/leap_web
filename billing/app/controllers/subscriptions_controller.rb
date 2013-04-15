class SubscriptionsController < ApplicationController
  before_filter :authorize

  def new
    # don't show link to subscribe if they are already subscribed?
    customer = Customer.find_by_user_id(current_user.id)

    if subscription = customer.single_subscription
      redirect_to subscription_path(subscription.id)
    else
      credit_card = customer.default_credit_card #safe to assume default?
      @payment_method_token = credit_card.token
      @plans = Braintree::Plan.all
    end
  end

  def show
    @subscription = Braintree::Subscription.find params[:id]
  end


  def create
    @result = Braintree::Subscription.create( :payment_method_token => params[:payment_method_token], :plan_id => params[:plan_id] )
  end

end
