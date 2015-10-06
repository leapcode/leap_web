require 'test_helper'
require 'fake_braintree'

class PaymentsControllerTest < ActionController::TestCase
  include CustomerTestHelper

  def setup
    FakeBraintree.activate!
  end

  def teardown
    FakeBraintree.clear!
  end

  test "payment new" do
    get :new

    assert_not_nil assigns(:client_token)
    assert_response :success
  end

  test "sucess confirmation" do
    #already included with FakeBraintree
    #Braintree::Transaction.sale.expects(:confirm).returns(success_response)
    post :confirm, {
      amount: "100",
      payment_method_nonce: "fake-valid-nonce",
      customer: {
         first_name: "Test",
         last_name: "Testing",
         company: "RGSoC",
         email: "any@email.com",
         phone: "555-888-1234" }
    }

    assert assigns(:result).success?
    assert_not_nil flash[:success]
  end

  test "failed confirmation renders new" do
    FakeBraintree.decline_all_cards!
    post :confirm, {
      amount: "100",
      payment_method_nonce: "fake-valid-nonce",
      customer: {
         first_name: "Test",
         last_name: "Testing",
         company: "RGSoC",
         email: "any@email.com",
         phone: "555-888-1234" }
    }

    assert !assigns(:result).success?
    assert_not_nil flash[:error]
    FakeBraintree.clear!
  end

  # that's what you get when not following the law of demeter...
end
