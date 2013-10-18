require 'test_helper'
require 'fake_braintree'

class SubscriptionsControllerTest < ActionController::TestCase
  include CustomerTestHelper

  test "destroy cancels subscription" do
    customer = stub_customer
    login customer.user
    result = Braintree::Subscription.create plan_id: 'my_plan',
      payment_method_token: customer.braintree_customer.credit_cards.first.token
    subscription = result.subscription
    delete :destroy, id: subscription.id, user_id: customer.user.id
    assert_equal "Canceled", Braintree::Subscription.find(subscription.id).status
  end
end
