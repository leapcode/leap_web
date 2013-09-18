module CustomerTestHelper

  def stub_customer(user = nil)
    user ||= find_record :user
    customer = stub_record :customer_with_payment_info, user: user
    Customer.stubs(:find_by_user_id).with(user.id).returns(customer)
    return customer
  end
end
