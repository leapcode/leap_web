class PaymentsController < BillingBaseController
  before_filter :require_login, :only => [:index]

  def new
    if current_user.has_payment_info?
      @client_token = Braintree::ClientToken.generate(customer_id: current_user.braintree_customer_id)
    else
      @client_token = Braintree::ClientToken.generate
   end
  end

  def index
    access_denied unless admin? or (@user == current_user)
    customer = Customer.find_by_user_id(@user.id)
    braintree_data = Braintree::Customer.find(customer.braintree_customer_id)
    # these will be ordered by created_at descending, per http://stackoverflow.com/questions/16425475/
    @transactions = braintree_data.transactions
  end

  def confirm
    make_transaction
    if @result.success?
      flash[:success] = "Congratulations! Your transaction has been successfully!"
    else
      flash[:error] = "Something went wrong while processing your donation. Please try again!"
    end
    redirect_to action: :new, locale: params[:locale]
  end

  private
  def make_transaction
    unless current_user.has_payment_info?
      transact_with_user_info
    else
      transact_without_user_info
    end
  end

  def transact_with_user_info
    @result = Braintree::Transaction.sale(
               amount: params[:amount],
               payment_method_nonce: params[:payment_method_nonce],
               customer: {
                  first_name: params[:first_name],
                  last_name: params[:last_name],
                  company: params[:company],
                  email: current_user.email,
                  phone: params[:phone]
                },
                options: {
                  store_in_vault: true
                })
    current_user.update_attributes(braintree_customer_id: @result.transaction.customer_details.id) if @result.success?
  end

  def transact_without_user_info
    @result = Braintree::Transaction.sale(
               amount: params[:amount],
               payment_method_nonce: params[:payment_method_nonce],
              )
  end
end
