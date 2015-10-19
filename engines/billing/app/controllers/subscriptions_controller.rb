class SubscriptionsController < BillingBaseController
  before_filter :require_login
  before_filter :assign_user
  before_filter :confirm_cancel_subscription, only: [:destroy]
  before_filter :generate_client_token, only: [:show]
  before_filter :get_braintree_customer, only: [:subscribe]

  def index
    if @user.subscription_id
      @subscription = Braintree::Subscription.find @user.subscription_id
      @plan = Braintree::Plan.all.select{ |plan| plan.id == @subscription.plan_id }.first
    else
      @subscriptions = Braintree::Plan.all
    end
  end

  def show
    @plan = Braintree::Plan.all.select{ |plan| plan.id == params[:id] }.first
  end

  def subscribe
    @result = Braintree::Subscription.create(payment_method_token: @customer.payment_methods.first.token,
                                             plan_id: params[:id])
    if @result.success?
      @user.update_attributes subscription_id: @result.subscription.id
      flash[:success] = I18n.t(:subscription_sucess)
    else
      flash[:error] = I18n.t(:subscription_not_sucess)
    end
    redirect_to action: :index, locale: params[:locale]
  end

  def unsubscribe
    @result = Braintree::Subscription.cancel(@user.subscription_id)
    if @result.success?
      @user.update_attributes subscription_id: nil
      flash[:success] = I18n.t(:unsubscription_sucess)
    else
      flash[:error] = I18n.t(:unsubscription_not_sucess)
    end
    redirect_to action: :index, locale: params[:locale]
  end

  private
  def assign_user
    @user = current_user
  end

  def generate_client_token
    if current_user.braintree_customer_id
      @client_token = Braintree::ClientToken.generate(customer_id: current_user.braintree_customer_id)
    else
     @client_token = Braintree::ClientToken.generate
    end
  end

  def get_braintree_customer
    if current_user.braintree_customer_id
      @customer = Braintree::Customer.find(current_user.braintree_customer_id)
    else
      @customer = Braintree::Customer.create(
                              payment_method_nonce: params[:payment_method_nonce],
                              first_name: params[:first_name],
                              last_name: params[:last_name],
                              company: params[:company],
                              email: current_user.email,
                              phone: params[:phone]
                            ).customer
      current_user.update_attributes braintree_customer_id: @customer.id
    end
  end
end
