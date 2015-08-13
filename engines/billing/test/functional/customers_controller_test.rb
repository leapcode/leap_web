require 'test_helper'
require 'fake_braintree'

class CustomersControllerTest < ActionController::TestCase
  tests CustomerController

  setup do
    InviteCodeValidator.any_instance.stubs(:not_existent?).returns(false)
    @user = FactoryGirl.create :user
    @other_user = FactoryGirl.create :user
    #FakeBraintree.clear!
    #FakeBraintree.verify_all_cards!
    testid = 'testid'
    #this wasn't actually being used
    #FakeBraintree::Customer.new({:credit_cards => [{:number=>"5105105105105100", :expiration_date=>"05/2013"}]}, {:id => testid, :merchant_id => Braintree::Configuration.merchant_id})
    # any reason to call the create instance method on the FakeBraintree::Customer ?
    @customer = Customer.new(:user_id => @other_user.id)
    @customer.braintree_customer_id = testid
    @customer.save

  end

  teardown do
    @user.destroy
    @other_user.destroy
    @customer.destroy
  end

  test "no access if not logged in" do
    get :new
    assert_login_required
    get :show, :id => @customer.braintree_customer_id
    assert_login_required
    get :edit, :id => @customer.braintree_customer_id
    assert_login_required
  end


  test "should get new if logged in and not customer" do
    login @user
    get :new
    assert_not_nil assigns(:tr_data)
    assert_response :success
  end

  test "new should direct edit if user is already a customer" do
    login @other_user
    get :new
    assert_response :redirect
    assert_equal edit_customer_url(@customer.user), response.header['Location']
  end


  test "show" do
    skip "show customer"
    login @other_user
    # Below will fail, as when we go to fetch the customer data, Braintree::Customer.find(params[:id]) won't find the customer as it is a FakeBraintree customer.
    #get :show, :id => @customer.braintree_customer_id

  end

end
