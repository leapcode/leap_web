require 'test_helper'
require 'fake_braintree'
require 'capybara/rails'

class CustomerCreationTest < ActionDispatch::IntegrationTest
  include Warden::Test::Helpers
  include Capybara::DSL

  setup do
    Warden.test_mode!
    @user = FactoryGirl.create(:user)
    login_as @user
  end

  teardown do
    Warden.test_reset!
  end

  # Let's test both steps together with capybara
  #
  # This test is nice and clean but also a bit fragile:
  # RackTest assumes all requests to be local. So we need
  # BraintreeTestApp for the braintree transparent redirect to work.
  #
  # this mystifies me why this works. when i type the click_button line (and the
  # customer.braintree_customer line) in the debugger, it gives a timeout,
  # but it works fine embedded in the test.
  test "create customer with braintree" do
    visit '/'
    click_link 'Billing Settings'
    # i am a bit unclear why this works, as it seems there will be validation errors
    assert_difference("Customer.count") do
      click_button 'Save Payment Info' # this gives me a timeout
    end
    assert customer = Customer.find_by_user_id(@user.id)
    assert customer.braintree_customer
  end

  # We only test the confirmation here.
  # The request to Braintree is triggered outside of rails
  # In skippped test below, we see this works even if the attributes are
  # for a broken customer
  test "successfully confirms customer creation" do
    response = post_transparent_redirect :create_customer_data,
      customer: FactoryGirl.attributes_for(:braintree_customer),
      redirect_url: confirm_customer_url

    assert_difference("Customer.count") do
      post response['Location']
    end

    assert_equal 200, status
    assert customer = Customer.find_by_user_id(@user.id)
    assert customer.braintree_customer
  end


  test "failed  customer creation" do
    skip "cannot get customer creation to fail"

    FakeBraintree.decline_all_cards!
    response = post_transparent_redirect :create_customer_data,
      customer: FactoryGirl.attributes_for(:broken_customer),
      redirect_url: confirm_customer_url

    assert_no_difference("Customer.count") do
      post response['Location'] #this gives me a timeout when run alone
    end
    assert_nil Customer.find_by_user_id(@user.id)

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

end
