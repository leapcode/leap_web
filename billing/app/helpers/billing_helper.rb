module BillingHelper

  def braintree_form_for(object, options = {}, &block)
    options.reverse_merge! params: @result && @result.params[object],
      errors: @result && @result.errors.for(object),
      builder: BraintreeFormHelper::BraintreeFormBuilder,
      url: Braintree::TransparentRedirect.url

    form_for object, options, &block
  end

  def billing_top_link(user)
    # for admins, top link will show special admin information, which has link to show their own customer information
    if (admin? and user == current_user)
      billing_admin_path
    else
      show_or_new_customer_link(user)
    end
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

  # a bit strange to put here, but we don't have a subscription model
  def user_for_subscription(subscription)

    if (transaction = subscription.transactions.first)
      # much quicker, but will only work if there is already a transaction associated with subscription (should generally be)
      braintree_customer = transaction.customer_details
    else
      search_results = Braintree::Customer.search do |search|
        search.payment_method_token.is subscription.payment_method_token
      end
      braintree_customer = search_results.first
    end

    customer = Customer.find_by_braintree_customer_id(braintree_customer.id)
    user = User.find(customer.user_id)

  end

end
