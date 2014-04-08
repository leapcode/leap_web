Dir.glob(Rails.root.join('*','test','factories.rb')) do |factory_file|
  require factory_file
end
FactoryGirl.define do

  factory :user do
    login { Faker::Internet.user_name }
    password_verifier "1234ABCD"
    password_salt "4321AB"

    factory :user_with_settings do
      email_forward { Faker::Internet.email }
      email_aliases_attributes do
        {:a => Faker::Internet.user_name + '@' + APP_CONFIG[:domain]}
      end
    end

    factory :admin_user do
      after(:build) do |admin|
        admin.stubs(:is_admin?).returns(true)
      end
    end
  end

  factory :token do
    user
  end

  factory :pgp_key do
    keyblock <<-EOPGP
-----BEGIN PGP PUBLIC KEY BLOCK-----
+Dummy+PGP+KEY+++Dummy+PGP+KEY+++Dummy+PGP+KEY+++Dummy+PGP+KEY+
#{SecureRandom.base64(4032)}
-----END PGP PUBLIC KEY BLOCK-----
    EOPGP
  end
end
