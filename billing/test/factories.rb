FactoryGirl.define do

  TEST_CC_NUMBER = %w(4111 1111 1111 1111).join

  factory :customer do
    user

    factory :customer_with_payment_info do
      braintree_customer
    end
  end

  factory :braintree_customer, class: Braintree::Customer do
    first_name 'Big'
    last_name 'Spender'
    credit_card number: TEST_CC_NUMBER, expiration_date: '04/2016'
    initialize_with { Braintree::Customer.create(attributes).customer }
    skip_create

    factory :broken_customer do
      credit_card number: '123456', expiration_date: '04/2016'
    end
  end

end
