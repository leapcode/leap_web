class PaymentsController < ApplicationController
  def new
    @amount = calculate_amount
    if current_user
      if @customer = Customer.find_by_user_id(current_user.id)
        @braintree_data = Braintree::Customer.find(@customer.braintree_customer_id)
        @default_cc = @braintree_data.credit_cards.find { |cc| cc.default? }
        @tr_data = Braintree::TransparentRedirect.transaction_data(:redirect_url => confirm_payment_url,
                                                                   :transaction => {:type => "sale", :amount => @amount, :customer_id => @customer.braintree_customer_id, :options => {:submit_for_settlement => true } })
      else
        redirect_to new_customer_path
      end
    else
      # anonymous payment not attributed to any user (ie, donation)
      @tr_data = Braintree::TransparentRedirect.transaction_data(:redirect_url => confirm_payment_url,
                                                                 :transaction => {:type => "sale", :amount => @amount, :options => {:submit_for_settlement => true } })
    end

  end

  def confirm
    @result = Braintree::TransparentRedirect.confirm(request.query_string)
    if @result.success?
      render :action => "confirm"
    else
      @amount = calculate_amount
      render :action => "new"
    end
  end

  protected

  def calculate_amount
    # in a real app this be calculated from a shopping cart, determined by the product, etc.
    "100.00"
  end
end
