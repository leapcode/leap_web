require 'test_helper'

class CustomerTest < ActiveSupport::TestCase

  setup do
    @customer = FactoryGirl.build(:customer)
  end

  test "test set of attributes should be valid" do
    @customer.valid?
    assert_equal Hash.new, @customer.errors.messages
  end

  test "customer belongs to user" do
    assert_equal User, @customer.user.class
  end

  test "user validation" do
    @customer.user = nil
    assert !@customer.valid?
  end

  test "has no payment info" do
    assert !@customer.braintree_customer_id
    assert !@customer.has_payment_info?
  end

  test "with no braintree data" do
    skip "this is currently commented out in the model"
    assert_equal @customer, @customer.with_braintree_data!
  end

  test "without default credit card" do
    assert_nil @customer.default_credit_card
  end

end
