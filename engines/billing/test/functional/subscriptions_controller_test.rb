require 'test_helper'
require 'fake_braintree'

class SubscriptionsControllerTest < ActionController::TestCase
  include CustomerTestHelper

  def setup
    FakeBraintree.activate!
  end

  def teardown
    FakeBraintree.clear!
  end

  test "get all subscriptions when the user doesn't have an active subscription" do
    user = find_record :user
    login user
    plans = [stub(:id => 1, :name => "First Plan", :price => 10), stub(:id => 2, :name => "Other Plan", :price => 30)]
    Braintree::Plan.expects(:all).returns(plans)

    get :index

    assert assigns(:subscriptions)
    assert_response :success
  end

  test "get subscriptions when user has an active subscription" do
    user = find_record :user
    login user
    plans = [stub(:id => 1, :name => "First Plan", :price => 10), stub(:id => 2, :name => "Other Plan", :price => 30)]
    Braintree::Plan.expects(:all).returns(plans)
    result = Braintree::Subscription.create(payment_method_token: 'user_token', plan_id: 1)
    user.subscription_id = result.subscription.id

    get :index

    assert assigns(:subscription)
    assert assigns(:plan)
    assert_response :success
  end

  test "subscriptions show" do
    user = find_record :user
    login user
    plans = [stub(:id => "1", :name => "First Plan", :price => 10), stub(:id => "2", :name => "Other Plan", :price => 30)]
    Braintree::Plan.expects(:all).returns(plans)

    get :show, :id => "1"

    assert assigns(:plan)
    assert_response :success
  end

 test "subscribe creates subscription" do
   user = find_record :user
   user.expects(:save).returns(true)
   login user
   payment_methods = [stub(:token => 'user_token')]
   Braintree::Customer.any_instance.stubs(:payment_methods).returns(payment_methods)
   user.expects(:save).returns(true)

   post :subscribe, :id => "1", :first_name => "Test", :last_name => "Testing", :company => "RGSoC", :email => "any@email.com", :phone => "555-888-1234"

   assert assigns(:result).success?
   assert_not_nil flash[:success]
 end

 test "unsubscribe cancels subscription" do
   user = find_record :user
   user.expects(:save).returns(true)
   result = Braintree::Subscription.create(payment_method_token: 'user_token', plan_id: '1')
   user.subscription_id = result.subscription.id
   login user

   delete :unsubscribe, :id => "1"

   assert assigns(:result).success?
   assert_not_nil flash[:success]
  end

end
