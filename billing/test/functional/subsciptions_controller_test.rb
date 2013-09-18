require 'test_helper'
require 'fake_braintree'

class SubscriptionsControllerTest < ActionController::TestCase

  test "destroy cancels subscription" do
    user = find_record :user
    customer = stub_record :customer_with_payment_info, user: user
    Customer.stubs(:find_by_user_id).with(user.id).returns(customer)
    login customer.user
    result = Braintree::Subscription.create plan_id: 'my_plan',
      payment_method_token: customer.braintree_customer.credit_cards.first.token
    subscription = result.subscription
    delete :destroy, id: subscription.id, user_id: customer.user.id
    assert_equal "Canceled", Braintree::Subscription.find(subscription.id).status
  end
end
