class SubscriptionController < ApplicationController
  before_filter :authorize

  def new
    customer = Customer.find_by_user_id(current_user.id)
    braintree_customer = Braintree::Customer.find(customer.braintree_customer_id)
    payment_method_token = customer.default_credit_card.token
    @result = Braintree::Subscription.create( :payment_method_token => payment_method_token, :plan_id => "ttw2" ) #todo obviously don't hardcode payment id
    debugger

  end

  def confirm
    
  end

end
