module BillingHelper

  def braintree_form_for(object, options = {}, &block)
    options.reverse_merge! params: @result && @result.params[object],
      errors: @result && @result.errors.for(object),
      builder: BraintreeFormHelper::BraintreeFormBuilder,
      url: Braintree::TransparentRedirect.url

    form_for object, options, &block
  end

  def show_or_new_customer_link(user)
    # Link to show if user is admin viewing another user, or user is already a customer.
    # Otherwise link to create a new customer.
    if (admin? and (user != current_user)) or ((customer = Customer.find_by_user_id(user.id)) and customer.has_payment_info?)
      show_customer_path(user)
    else
      new_customer_path
    end
  end

end
