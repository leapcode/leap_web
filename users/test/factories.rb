FactoryGirl.define do

  factory :user do
    login { Faker::Internet.user_name }
    password_verifier "1234ABCD"
    password_salt "4321AB"
  end

  factory :user_with_settings, :class => User do
    login { Faker::Internet.user_name }
    password_verifier "1234ABCD"
    password_salt "4321AB"
    email_forward { Faker::Internet.email }
    email_aliases_attributes do
      {:a => Faker::Internet.user_name + '@' + APP_CONFIG[:domain]}
    end
  end
end
