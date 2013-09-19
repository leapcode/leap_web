require 'test_helper'
require 'fake_braintree'

class CustomerControllerTest < ActionController::TestCase
  include CustomerTestHelper

  test "new assigns redirect url" do
    login
    get :new

    assert_response :success
    assert assigns(:tr_data)
    tr_data = Braintree::Util.parse_query_string(assigns(:tr_data))
    assert_equal confirm_customer_url, tr_data[:redirect_url]
  end

  test "new requires login" do
    get :new

    assert_response :redirect
    assert_redirected_to login_path
  end

  test "edit uses params[:id]" do
    customer = stub_customer
    login customer.user
    get :edit, id: customer.user.id

    assert_response :success
    assert assigns(:tr_data)
    tr_data = Braintree::Util.parse_query_string(assigns(:tr_data))
    assert_equal customer.braintree_customer_id, tr_data[:customer_id]
    assert_equal confirm_customer_url, tr_data[:redirect_url]
  end

  test "confirm customer creation" do
    login
    Braintree::TransparentRedirect.expects(:confirm).returns(success_response)
    # to_confirm = prepare_confirmation :create_customer_data,
    #   customer: FactoryGirl.attributes_for(:braintree_customer),
    #   redirect_url: confirm_customer_url

    assert_difference("Customer.count") do
      post :confirm, braintree: :query
    end

    assert_response :success
    assert result = assigns(:result)
    assert result.success?
    assert result.customer.id
  end

  test "customer update" do
    customer = stub_customer
    customer.expects(:save)
    login customer.user
    Braintree::TransparentRedirect.expects(:confirm).
      returns(success_response(customer))

    assert_no_difference("Customer.count") do
      post :confirm, query: :from_braintree
    end

    assert_response :success
    assert result = assigns(:result)
    assert result.success?
    assert_equal customer.braintree_customer, result.customer
  end

  test "failed customer creation" do
    skip "can't get customer creation to fail"
    login
    FakeBraintree.decline_all_cards!
    # what is prepare_confirmation ?? this method isn't found
    to_confirm = prepare_confirmation :create_customer_data,
      customer: FactoryGirl.attributes_for(:broken_customer),
      redirect_url: confirm_customer_url
    post :confirm, to_confirm

    FakeBraintree.clear!
    assert_response :success
    assert result = assigns(:result)
    assert !result.success?
  end

  test "failed customer creation with stubbing" do
    login
    Braintree::TransparentRedirect.expects(:confirm).returns(failure_response)
    post :confirm, bla: :blub

    assert_response :success
    assert_template :new
  end

  test "failed customer update with stubbing" do
    customer = stub_customer
    login customer.user
    Braintree::TransparentRedirect.expects(:confirm).returns(failure_response)
    post :confirm, bla: :blub

    assert_response :success
    assert_template :edit
  end

  def failure_response
    stub success?: false,
      errors: stub(for: nil, size: 0),
      params: {}
  end

  def success_response(customer = nil)
    stub success?: true,
      customer: braintree_customer(customer)
  end

  def braintree_customer(customer)
    if customer
      customer.braintree_customer
    else
      FactoryGirl.build :braintree_customer
    end
  end

end
