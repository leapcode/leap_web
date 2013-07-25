module BillingHelper

  def braintree_form_for(object, options = {}, &block)
    options.reverse_merge! params: @result && @result.params[object],
      errors: @result && @result.errors.for(object),
      builder: BraintreeFormHelper::BraintreeFormBuilder,
      url: Braintree::TransparentRedirect.url

    form_for object, options, &block
  end

  def show_or_new_customer_link(user)
    if (customer = Customer.find_by_user_id(user.id)) and customer.has_payment_info?
      show_customer_path(user)
    else
      new_customer_path
    end
  end

end
