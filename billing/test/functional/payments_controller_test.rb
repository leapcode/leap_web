require 'test_helper'
require 'fake_braintree'

class PaymentsControllerTest < ActionController::TestCase
  include CustomerTestHelper

  test "payment when unauthorized" do
    get :new
    assert_not_nil assigns(:tr_data)
    assert_response :success
  end

  test "authenticated user must create account before making payment" do
    login
    get :new
    assert_response :redirect
    assert_equal new_customer_url, response.header['Location']
  end

  test "payment when authenticated as customer" do
    customer = stub_customer
    login customer.user
    get :new
    assert_not_nil assigns(:tr_data)
    assert_response :success
  end

  test "successful confirmation renders confirm" do
    Braintree::TransparentRedirect.expects(:confirm).returns(success_response)
    get :confirm

    assert_response :success
    assert_template :confirm
  end

  test "failed confirmation renders new" do
    Braintree::TransparentRedirect.expects(:confirm).returns(failure_response)
    get :confirm

    assert_response :success
    assert_not_nil assigns(:tr_data)
    assert_template :new
  end

  def failure_response
    stub success?: false,
      errors: stub(for: nil, size: 0),
      params: {},
      transaction: stub(status: nil)
  end

  def success_response
    stub success?: true,
      transaction: stub_transaction
  end

  # that's what you get when not following the law of demeter...
  def stub_transaction
    stub amount: "100.00",
      id: "ASDF",
      customer_details: FactoryGirl.build(:braintree_customer),
      credit_card_details: FactoryGirl.build(:braintree_customer).credit_cards.first
  end

end
