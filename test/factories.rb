ENGINE_FACTORY_FILES = Rails.root.join('engines','*','test','factories.rb')
Dir.glob(ENGINE_FACTORY_FILES) do |factory_file|
  require factory_file
end

FactoryGirl.define do

  factory :user do
    # Faker::Internet.user_name alone was sometimes
    # producing duplicate usernames.
    login { Faker::Internet.user_name + '_' + SecureRandom.hex(4) }
    password_verifier "1234ABCD"
    password_salt "4321AB"
    invite_code "testcode"


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

    factory :premium_user do
      effective_service_level_code 2
    end

  end

  # Identities can have a lot of different purposes - alias, forward, ...
  # So far this is a blocked handle only.
  factory :identity do
    address {Faker::Internet.user_name + '@' + APP_CONFIG[:domain]}
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

  factory :message do
    text Faker::Lorem.paragraph
  end
end
