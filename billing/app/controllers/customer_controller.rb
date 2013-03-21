class CustomerController < ApplicationController
  before_filter :authorize

  def new
    @tr_data = Braintree::TransparentRedirect.
                create_customer_data(:redirect_url => confirm_customer_url)
  end

  def edit
    customer = Customer.find_by_user_id(current_user.id)
    #current_customer.with_braintree_data!
    # @credit_card = current_customer.default_credit_card
    @braintree_data = Braintree::Customer.find(customer.braintree_customer_id)
    @default_cc = @braintree_data.credit_cards.find { |cc| cc.default? }
    @tr_data = Braintree::TransparentRedirect.
                update_customer_data(:redirect_url => confirm_customer_url,
                                     :customer_id => customer.braintree_customer_id)
  end

  def confirm
    @result = Braintree::TransparentRedirect.confirm(request.query_string)

    if @result.success?
      # customer = Customer.new(:user_id => current_user.id, :braintree_customer_id =>  @result.customer.id)
      customer = Customer.new(:braintree_customer_id =>  @result.customer.id)
      customer.user = current_user
      customer.save
      #current_user.save!
      render :action => "confirm"
    #elsif current_user.has_payment_info?
    elsif (customer = Customer.find_by_user_id(current_user.id)) and customer.has_payment_info?
      customer.with_braintree_data! #todo
      render :action => "edit"
    else
      render :action => "new"
    end
  end
end
