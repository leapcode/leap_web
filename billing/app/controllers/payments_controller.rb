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
    access_denied unless admin? or (@user == current_user)
    customer = Customer.find_by_user_id(@user.id)
    braintree_data = Braintree::Customer.find(customer.braintree_customer_id)
    # these will be ordered by created_at descending, per http://stackoverflow.com/questions/16425475/
    @transactions = braintree_data.transactions
  end

  protected


  def fetch_transparent_redirect
    @tr_data = Braintree::TransparentRedirect.transaction_data redirect_url: confirm_payment_url,
      transaction: { type: "sale", options: {submit_for_settlement: true } }
  end

end
