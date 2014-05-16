require 'test_helper'
require 'fake_braintree'

class CustomerWithPaymentInfoTest < ActiveSupport::TestCase
  include StubRecordHelper

  setup do
    @user = find_record :user
    @customer = FactoryGirl.build(:customer_with_payment_info, user: @user)
  end

  test "has payment_info" do
    assert @customer.braintree_customer_id
    assert @customer.has_payment_info?
  end

  test "constructs customer with braintree data" do
    @customer.with_braintree_data!
    assert_equal 'Big', @customer.first_name
    assert_equal 'Spender', @customer.last_name
    assert_equal 1, @customer.credit_cards.size
    assert_equal Hash.new, @customer.custom_fields
  end

  test "can access braintree_customer after reload" do
    @customer.save
    @customer = Customer.find_by_user_id(@customer.user_id)
    @customer.with_braintree_data!
    assert_equal 'Big', @customer.first_name
    assert_equal 'Spender', @customer.last_name
    assert_equal 1, @customer.credit_cards.size
    assert_equal Hash.new, @customer.custom_fields
    @customer.destroy
  end

  test "sets default_credit_card" do
    @customer.with_braintree_data!
    assert_equal @customer.credit_cards.first, @customer.default_credit_card
  end
end
