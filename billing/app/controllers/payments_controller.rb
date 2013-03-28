class PaymentsController < ApplicationController
  def new
    if current_user
      if @customer = Customer.find_by_user_id(current_user.id)
        @braintree_data = Braintree::Customer.find(@customer.braintree_customer_id)
        @default_cc = @braintree_data.credit_cards.find { |cc| cc.default? }
        @tr_data = transparent_redirect(@customer.braintree_customer_id)
      else
        redirect_to new_customer_path
      end
    else
      # anonymous payment not attributed to any user (ie, donation)
      @tr_data = transparent_redirect
    end

  end

  def confirm
    @result = Braintree::TransparentRedirect.confirm(request.query_string)
    if @result.success?
      render :action => "confirm"
    else
      render :action => "new"
    end
  end

  protected

  def transparent_redirect(braintree_customer_id = nil)
    Braintree::TransparentRedirect.transaction_data(:redirect_url => confirm_payment_url,
                                                    :transaction => {:type => "sale", :customer_id => braintree_customer_id, :options => {:submit_for_settlement => true } })

  end


end
