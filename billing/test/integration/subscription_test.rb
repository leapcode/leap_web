require 'test_helper'
require 'fake_braintree'
require 'capybara/rails'

class SubscriptionTest < ActionDispatch::IntegrationTest
  include Warden::Test::Helpers
  include Capybara::DSL
  include CustomerTestHelper
  include StubRecordHelper

  setup do
    Warden.test_mode!
    @admin = stub_record :user, :admin => true
    @customer = stub_customer
    @braintree_customer = @customer.braintree_customer
    response = Braintree::Subscription.create plan_id: '5',
      payment_method_token: @braintree_customer.credit_cards.first.token
    @subscription = response.subscription
    Capybara.current_driver = Capybara.javascript_driver
  end

  teardown do
    Warden.test_reset!
  end

  test "admin can see subscription for another" do
    login_as @admin
    @customer.stubs(:subscriptions).returns([@subscription])
    visit user_subscriptions_path(@customer.user_id)
    assert page.has_content?("Subscriptions")
    assert page.has_content?("Status: Active")
    page.save_screenshot('/tmp/subscriptions.png')
  end

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
