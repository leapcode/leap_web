class CustomerController < BillingBaseController
  before_filter :authorize, :fetch_customer

  def show
    if @customer
      @customer.with_braintree_data!
      @default_cc = @customer.default_credit_card
      @active_subscription = @customer.subscriptions
      @transactions = @customer.braintree_customer.transactions
    end
  end

  def new
    if @customer.has_payment_info?
      redirect_to edit_customer_path(@user), :notice => 'Here is your saved customer data'
    else
      fetch_new_transparent_redirect_data
    end
  end

  def edit
    fetch_edit_transparent_redirect_data
  end

  def confirm
    @result = Braintree::TransparentRedirect.confirm(request.query_string)
    if @result.success?
      @customer.braintree_customer =  @result.customer
      @customer.save
      render :action => "confirm"
    elsif @customer.has_payment_info?
      fetch_edit_transparent_redirect_data
      render :action => "edit"
    else
      fetch_new_transparent_redirect_data
      render :action => "new"
    end
  end

  protected

  def fetch_new_transparent_redirect_data
    access_denied unless @user == current_user # admins cannot do this for others
    @tr_data = Braintree::TransparentRedirect.
      create_customer_data(:redirect_url => confirm_customer_url)
  end

  def fetch_edit_transparent_redirect_data
    access_denied unless @user == current_user # admins cannot do this for others
    @customer.with_braintree_data!
    @default_cc = @customer.default_credit_card
    @tr_data = Braintree::TransparentRedirect.
      update_customer_data(:redirect_url => confirm_customer_url,
                           :customer_id => @customer.braintree_customer_id) ##??
  end

  def fetch_customer
    @customer = Customer.find_by_user_id(@user.id)
    if @user == current_user
      @customer ||= Customer.new(user: @user)
    end
    access_denied unless (@customer and (@customer.user == current_user)) or admin?
  end
end
