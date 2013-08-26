module BillingHelper

  def braintree_form_for(object, options = {}, &block)
    options.reverse_merge! params: @result && @result.params[object],
      errors: @result && @result.errors.for(object),
      builder: BraintreeFormHelper::BraintreeFormBuilder,
      url: Braintree::TransparentRedirect.url

    form_for object, options, &block
  end

end
