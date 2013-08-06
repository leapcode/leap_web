class PaymentsController < BillingBaseController
  before_filter :authorize, :only => [:index]

  def new
    fetch_transparent_redirect
  end

  def confirm
    @result = Braintree::TransparentRedirect.confirm(request.query_string)
    if @result.success?
      render :action => "confirm"
    else
      fetch_transparent_redirect
      render :action => "new"
    end
  end

  def index
    customer = Customer.find_by_user_id(@user.id)
    braintree_data = Braintree::Customer.find(customer.braintree_customer_id)
    # these will be ordered by created_at descending, per http://stackoverflow.com/questions/16425475/
    # TODO permissions
    @transactions = braintree_data.transactions
  end

  protected


  def fetch_transparent_redirect
    if @user = current_user #set user for navigation
      if @customer = Customer.find_by_user_id(current_user.id)
        @customer.with_braintree_data!
        braintree_customer_id = @customer.braintree_customer_id
        @default_cc = @customer.default_credit_card
      else
        # TODO: this requires user to add self to vault before making payment. Is that desired functionality?
        redirect_to new_customer_path, :notice => 'Before making payment, please add your customer data'
      end
    end

    # TODO: What is this supposed to do if braintree_customer_id was not set yet?
    # Response: it can be used to make a payment that is not attributed to any customer (ie, a donation)
    @tr_data = Braintree::TransparentRedirect.transaction_data redirect_url: confirm_payment_url,
      transaction: { type: "sale", customer_id: braintree_customer_id, options: {submit_for_settlement: true } }
  end

end
