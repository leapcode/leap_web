class CreditCardInfoController < ApplicationController
  before_filter :authorize

  def edit
    @credit_card = Braintree::CreditCard.find(params[:id])
    customer = Customer.find_by_user_id(current_user.id)
    if customer and customer.braintree_customer_id == @credit_card.customer_id
      @tr_data = Braintree::TransparentRedirect.
        update_credit_card_data(:redirect_url => confirm_credit_card_info_url,
                                :payment_method_token => @credit_card.token)
    else
      access_denied
    end

  end

  def confirm
    @result = Braintree::TransparentRedirect.confirm(request.query_string)
    if @result.success?
      render :action => "confirm"
    else
      @credit_card = Braintree::CreditCard.find(@result.params[:payment_method_token])
      render :action => "edit"
    end
  end

end
