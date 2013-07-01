FactoryGirl.define do

  factory :customer do
    user

    factory :braintree_customer do
      braintree_customer_id { 1 }
    end
  end

end
