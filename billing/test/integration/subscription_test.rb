require 'test_helper'
require 'fake_braintree'
require 'capybara/rails'

class SubscriptionTest < ActionDispatch::IntegrationTest
  include Warden::Test::Helpers
  include Capybara::DSL

  setup do
    Warden.test_mode!
    @admin = User.find_by_login('admin') || FactoryGirl.create(:user, login: 'admin')
    @customer = FactoryGirl.create(:customer)
    @braintree_customer = FactoryGirl.create(:braintree_customer)
    @customer.braintree_customer_id = @braintree_customer.id
    @customer.save
    @subscription = FakeBraintree::Subscription.new({:payment_method_token => @braintree_customer.credit_cards.first, :plan_id => '5'}, {:id => @braintree_customer.id, :merchant_id => Braintree::Configuration.merchant_id})
    # unfortunately @braintree_customer.credit_cards.first.subscriptions still returns empty array
  end

  teardown do
    Warden.test_reset!
    @admin.destroy
    @customer.destroy
  end

  test "admin can cancel subscription for another" do
    skip "not sure about testing admin cancelling subscription with fake_braintree"
    login_as @admin
    #visit user_subscriptions_path(@customer.user_id)
    #delete :destroy, :id => @subscription.id
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
