require 'test_helper'
require 'fake_braintree'

class CustomerControllerTest < ActionController::TestCase

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

  test "edit uses current_user" do
    customer = FactoryGirl.create :customer_with_payment_info
    login customer.user
    get :edit, id: :unused

    assert_response :success
    assert assigns(:tr_data)
    tr_data = Braintree::Util.parse_query_string(assigns(:tr_data))
    assert_equal customer.braintree_customer_id, tr_data[:customer_id]
    assert_equal confirm_customer_url, tr_data[:redirect_url]
  end

  test "confirm user creation" do
    login
    to_confirm = prepare_confirmation :create_customer_data,
      customer: FactoryGirl.attributes_for(:braintree_customer),
      redirect_url: confirm_customer_url
    post :confirm, to_confirm

    assert_response :success
    assert result = assigns(:result)
    assert result.success?
    assert result.customer.id
  end

  test "failed user creation" do
    skip "can't get user creation to fail"
    login
    FakeBraintree.decline_all_cards!
    to_confirm = prepare_confirmation :create_customer_data,
      customer: FactoryGirl.attributes_for(:broken_customer),
      redirect_url: confirm_customer_url
    post :confirm, to_confirm

    FakeBraintree.clear!
    assert_response :success
    assert result = assigns(:result)
    assert !result.success?
  end

  test "failed user creation with stubbing" do
    login
    Braintree::TransparentRedirect.expects(:confirm).returns(failure_response)
    post :confirm, bla: :blub

    assert_response :success
    assert_template :new
  end

  test "failed user update with stubbing" do
    customer = FactoryGirl.create :customer_with_payment_info
    login customer.user
    Braintree::TransparentRedirect.expects(:confirm).returns(failure_response)
    post :confirm, bla: :blub

    assert_response :success
    assert_template :edit
  end

  def prepare_confirmation(type, data)
    parse_redirect post_transparent_redirect(type, data)
  end

  def failure_response
    stub success?: false,
      errors: stub(for: nil, size: 0),
      params: {}
  end

  def post_transparent_redirect(type, data)
    params = data.dup
    params[:tr_data] = Braintree::TransparentRedirect.send(type, params)
    post_transparent_redirect_params(params)
  end

  def post_transparent_redirect_params(params)
    uri = URI.parse(Braintree::TransparentRedirect.url)
    Net::HTTP.start(uri.host, uri.port) do |http|
      http.post(uri.path, Rack::Utils.build_nested_query(params))
    end
  end

  def parse_redirect(response)
    uri = URI.parse(response['Location'])
    Braintree::Util.parse_query_string uri.query
  end

end
