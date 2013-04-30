require 'test_helper'

class PaymentsControllerTest < ActionController::TestCase

  setup do
    FakeBraintree.clear!
    @user = FactoryGirl.create :user
    @other_user = FactoryGirl.create :user
    FakeBraintree.clear!
    FakeBraintree.verify_all_cards!
    testid = 'testid'
    FakeBraintree::Customer.new({:credit_cards => [{:number=>"5105105105105100", :expiration_date=>"05/2013"}]}, {:id => testid, :merchant_id => Braintree::Configuration.merchant_id})
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

  test "payment when unauthorized" do
    get :new
    assert_not_nil assigns(:tr_data)
    assert_response :success
  end

  test "authenticated user must create account before making payment" do
    login @user
    get :new
    assert_response :redirect
    assert_equal new_customer_url, response.header['Location']
  end

  test "payment when authenticated as customer" do
    get :new
    assert_not_nil assigns(:tr_data)
    assert_response :success
    #TODO check more here
  end

  # what would we test with something like this?
  test "fake transaction" do
    transaction = FakeBraintree.generate_transaction(:amount => '20.00',
                                                     #:status => Braintree::Transaction::Status::Settled,
                                                     #:subscription_id => 'foobar',
                                                     )

  end


end
