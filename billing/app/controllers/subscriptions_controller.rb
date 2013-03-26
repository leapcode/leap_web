class SubscriptionsController < ApplicationController
  before_filter :authorize

  def new
    customer = Customer.find_by_user_id(current_user.id)
    @payment_method_token = customer.default_credit_card.token
    @plans = Braintree::Plan.all

  end

  def create
    @result = Braintree::Subscription.create( :payment_method_token => params[:payment_method_token], :plan_id => params[:plan_id] )
  end

end
