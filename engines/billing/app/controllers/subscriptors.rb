def braintree_customer
  if current_user.braintree_customer_id
    Braintree::Customer.find current_user.braintree_customer_id
  else
    customer = Braintree::Customer.create(payment_method_nonce: params[:payment_method_nonce]).customer
    current_user.update_attributes braintree_customer_id: customer.id
    customer
  end
end
