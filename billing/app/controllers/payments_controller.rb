class PaymentsController < ApplicationController
  before_filter :authorize, :only => [:index]

  def new
    if current_user
      if @customer = Customer.find_by_user_id(current_user.id)
        @braintree_data = Braintree::Customer.find(@customer.braintree_customer_id)
        @default_cc = @customer.default_credit_card(@braintree_data)
        @tr_data = transparent_redirect(@customer.braintree_customer_id)
      else
        # TODO: this requires user to add self to vault before making payment. Is that desired functionality?
        redirect_to new_customer_path, :notice => 'Before making payment, please add your customer data'
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

  def index
    customer = Customer.find_by_user_id(current_user.id)
    braintree_data = Braintree::Customer.find(customer.braintree_customer_id)
    @transactions = braintree_data.transactions
  end

  protected

  def transparent_redirect(braintree_customer_id = nil)
    Braintree::TransparentRedirect.transaction_data(:redirect_url => confirm_payment_url,
                                                    :transaction => {:type => "sale", :customer_id => braintree_customer_id, :options => {:submit_for_settlement => true } })
  end


end
