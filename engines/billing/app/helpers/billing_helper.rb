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
      subscriptions_path
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
      braintree_customer_id = transaction.customer_details.id
    else
      credit_card = Braintree::CreditCard.find(subscription.payment_method_token)
      braintree_customer_id = credit_card.customer_id
    end

    customer = Customer.find_by_braintree_customer_id(braintree_customer_id)
    user = User.find(customer.user_id)

  end

  def allow_cancel_subscription(subscription)
    ['Active', 'Pending'].include? subscription.status or (admin? and subscription.status == 'Past Due')
  end

end
