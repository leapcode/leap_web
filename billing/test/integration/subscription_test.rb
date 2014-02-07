require 'test_helper'
require 'fake_braintree'
require 'capybara/rails'

class SubscriptionTest < BrowserIntegrationTest
  include Warden::Test::Helpers
  include CustomerTestHelper
  include StubRecordHelper

  setup do
    Warden.test_mode!
    @admin = User.find_by_login('admin') || FactoryGirl.create(:user, login: 'admin')
    @customer = stub_customer
    @braintree_customer = @customer.braintree_customer
    response = Braintree::Subscription.create plan_id: '5',
      payment_method_token: @braintree_customer.credit_cards.first.token,
      price: '10'
    @subscription = response.subscription
  end

  teardown do
    Warden.test_reset!
    @admin.destroy
  end

  test "admin can see all subscriptions for another" do
    login_as @admin
    @customer.stubs(:subscriptions).returns([@subscription])
    @subscription.stubs(:balance).returns 0
    visit user_subscriptions_path(@customer.user_id, :locale => nil)
    assert page.has_content?("Subscriptions")
    assert page.has_content?("Status: Active")
  end

  # test "user cannot see all subscriptions for other user" do
  #end

  #test "admin cannot add subscription for another" do
  #end

  #test "authenticated user can cancel own subscription" do
  #end

  #test "user cannot add subscription if they have active one" do
  #end

  #test "user can view own subscriptions"
  #end

  #test "admin can view another user's subscriptions" do
  #end

end
