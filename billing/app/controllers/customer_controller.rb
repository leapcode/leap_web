class CustomerController < BillingBaseController
  before_filter :authorize
  before_filter :fetch_customer_data, :only => [:show, :edit] #confirm???

  def show
    @active_subscription = @customer.subscriptions(@braintree_data)
  end

  def new
    if customer = Customer.find_by_user_id(current_user.id)
      redirect_to edit_customer_path(customer.braintree_customer_id), :notice => 'Here is your saved customer data'
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
      # customer = Customer.new(:user_id => current_user.id, :braintree_customer_id =>  @result.customer.id)
      customer = Customer.new(:braintree_customer_id =>  @result.customer.id)
      customer.user = current_user
      customer.save
      #current_user.save!
      #debugger
      render :action => "confirm"
    #elsif current_user.has_payment_info?
    elsif (customer = Customer.find_by_user_id(current_user.id)) and customer.has_payment_info?
      #customer.with_braintree_data!
      fetch_edit_transparent_redirect_data
      render :action => "edit"
    else
      fetch_new_transparent_redirect_data
      render :action => "new"
    end
  end

  private

  def fetch_customer_data
    if ((@customer = Customer.find_by_user_id(current_user.id)) and
        (params[:id] == @customer.braintree_customer_id))
      @braintree_data = Braintree::Customer.find(params[:id]) #used in editing form
      @default_cc = @customer.default_credit_card(@braintree_data)
    else
      # TODO will want case for admins, presumably
      access_denied
    end
  end

  def fetch_new_transparent_redirect_data
    @tr_data = Braintree::TransparentRedirect.
      create_customer_data(:redirect_url => confirm_customer_url)
  end

  def fetch_edit_transparent_redirect_data
    @tr_data = Braintree::TransparentRedirect.
      update_customer_data(:redirect_url => confirm_customer_url,
                           :customer_id => params[:id]) ##??

  end

end
