require 'test_helper'

class CustomerTest < ActiveSupport::TestCase
  setup do
    #cannot get this working with FakeBraintree becuase the methods in customer.rb try to find the customer in braintree itself.

    @user = FactoryGirl.build(:user)
    @user.save
    @customer = Customer.new(:user_id => @user.id)

    result = Braintree::Customer.create()
    @customer.braintree_customer_id = result.customer.id
    @customer.save
    @braintree_customer_data = Braintree::Customer.find(@customer.braintree_customer_id)

    result = Braintree::Customer.create(:credit_card => { :number => "5105105105105100", :expiration_date => "05/2012"})
  end

  teardown do
    @user.destroy
    @customer.destroy
    Braintree::Customer.delete(@customer.braintree_customer_id)
  end

  test "default credit card" do
    assert_nil @customer.default_credit_card(@braintree_customer_data)
    Braintree::Customer.update(@customer.braintree_customer_id, :credit_card => { :number => "5105105105105100", :expiration_date => "05/2012" } )
    assert_not_nil @customer.default_credit_card
    assert_equal @customer.default_credit_card.expiration_date, "05/2012"
  end


  test "single subscription" do


  end

end
