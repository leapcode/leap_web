require_relative '../test_helper'

class AccountTest < ActiveSupport::TestCase

  setup do
    @testcode = InviteCode.new
    @testcode.save!
  end

  teardown do
    Identity.destroy_all_orphaned
  end

  test "create a new account when invited" do
    user = Account.create(user_attributes( :invite_code => @testcode.invite_code))
    assert user.valid?, "unexpected errors: #{user.errors.inspect}"
    assert user.persisted?
    assert id = user.identity
    assert_equal user.email_address, id.address
    assert_equal user.email_address, id.destination
    user.account.destroy
  end

  test "fail to create account without invite" do
    with_config invite_required: true do
      user = Account.create(user_attributes)
      assert !user.valid?, "user should not be valid"
      assert !user.persisted?, "user should not have been saved"
      assert_has_errors user, invite_code: "This is not a valid code"
    end
  end

  test "allow invite_required override" do
    with_config invite_required: true do
      user = Account.create(user_attributes, :invite_required => false)
      assert user.valid?, "unexpected errors: #{user.errors.inspect}"
      assert user.persisted?, "user should have been saved"
      user.account.destroy
    end
  end

  test "create a new account" do
    with_config invite_required: false do
      user = Account.create(user_attributes)
      assert user.valid?, "unexpected errors: #{user.errors.inspect}"
      assert user.persisted?
      user.account.destroy
    end
  end

  test "error on reused username" do
    with_config invite_required: false do
      attributes = user_attributes
      user = Account.create attributes
      dup = Account.create attributes
      assert !dup.valid?
      assert_has_errors dup, login: "has already been taken"
      user.account.destroy
    end
  end

  test "error on invalid username" do
    with_config invite_required: false do
      attributes = FactoryGirl.attributes_for :user, login: "a"
      user = Account.create attributes
      assert !user.valid?
      assert_has_errors user, login: "Must have at least two characters"
    end
  end

  test "create and remove a user account" do
    # We keep an identity that will block the handle from being reused.
    assert_difference "Identity.count" do
      assert_no_difference "User.count" do
        user = Account.create(user_attributes( :invite_code => @testcode.invite_code))
        user.account.destroy
      end
    end
  end

  test "change username and create alias" do
    user = Account.create(user_attributes( :invite_code => @testcode.invite_code))
    old_id = user.identity
    old_email = user.email_address
    user.account.update(user_attributes)
    user.reload
    old_id.reload
    assert user.valid?
    assert user.persisted?
    assert id = user.identity
    assert id.persisted?
    assert_equal user.email_address, id.address
    assert_equal user.email_address, id.destination
    assert_equal user.email_address, old_id.destination
    assert_equal old_email, old_id.address
    user.account.destroy
  end

  test "create recovery code if it does not exist" do
    user = Account.create(user_attributes( :invite_code => @testcode.invite_code))
    user.account.update(:recovery_code_verifier => "abc", :recovery_code_salt => "123")
    user.reload

    assert_equal "abc", user.recovery_code_verifier
    assert_equal "123", user.recovery_code_salt

    user.account.destroy
  end

  test "update recovery code that already exists" do
    user = Account.create(user_attributes(
      :invite_code => @testcode.invite_code,
      :recovery_code_verifier => "000",
      :recovery_code_salt => "111"))

    user.account.update(:recovery_code_verifier => "abc", :recovery_code_salt => "123")
    user.reload

    assert_equal "abc", user.recovery_code_verifier
    assert_equal "123", user.recovery_code_salt

    user.account.destroy
  end

  test "update password" do
    user = Account.create(user_attributes( :invite_code => @testcode.invite_code))
    user.account.update(:password_verifier => "551A8B", :password_salt => "551A8B")

    assert_equal "551A8B", user.password_verifier
    assert_equal "551A8B", user.password_salt

    user.account.destroy
  end

  test "Invite code count goes up by 1 when the invite code is entered" do
    with_config invite_required: true do
      user = Account.create(user_attributes( :invite_code => @testcode.invite_code))
      user_code = InviteCode.find_by_invite_code user.invite_code
      user.save
      assert user.persisted?
      assert_equal 1, user_code.invite_count
    end
  end

  test "Single use invite code is destroyed when used by test user" do
    with_config invite_required: true do
      attrs = user_attributes invite_code: @testcode.invite_code
      attrs[:login] = 'test_user_' + attrs[:login]
      user = Account.create(attrs)
      user.save
      assert user.persisted?, user.errors.inspect
      assert_nil InviteCode.find_by_invite_code user.invite_code
    end
  end

  test "Single use invite code is destroyed when used by tmp user" do
    with_config invite_required: true do
      attrs = user_attributes invite_code: @testcode.invite_code
      attrs[:login] = 'tmp_user_' + attrs[:login]
      user = Account.create(attrs)
      user.save
      assert user.persisted?, user.errors.inspect
      assert_nil InviteCode.find_by_invite_code user.invite_code
    end
  end

  test "Invite code stays zero when invite code is not used" do
    #user = Account.create(user_attributes( :invite_code => @testcode.invite_code))
    invalid_user = FactoryGirl.build(:user, :invite_code => @testcode.invite_code)
    invalid_user.save
    user_code = InviteCode.find_by_invite_code invalid_user.invite_code
    user_code.save

    assert_equal 0, user_code.invite_count
  end

  test "disabled accounts have no cert fingerprints" do
    user = Account.create(user_attributes)
    cert = stub(expiry: 1.month.from_now, fingerprint: SecureRandom.hex)
    user.identity.register_cert cert
    user.identity.save
    assert_equal(cert.fingerprint, Identity.for(user).cert_fingerprints.keys.first)
    user.account.disable
    assert_equal({}, Identity.for(user).cert_fingerprints)
    assert_equal(cert.fingerprint, Identity.for(user).read_attribute(:disabled_cert_fingerprints).keys.first)
    user.account.enable
    assert_equal(cert.fingerprint, Identity.for(user).cert_fingerprints.keys.first)
  end

  # Pixelated relies on the ability to test invite codes without sending a
  # username and password yet.
  # So we better make sure we return the appropriate errors
  test "errors trying to create account with invite only" do
    with_config invite_required: true do
      user = Account.create invite_code: @testcode.invite_code
      assert user.errors[:invite_code].blank?
    end
  end

  test "errors trying to create account with invalid invite only" do
    with_config invite_required: true do
      user = Account.create invite_code: "wrong_invite_code"
      assert_has_errors user, invite_code: "This is not a valid code"
    end
  end

  protected

  # Tests for the presence of the errors given.
  # Does not test for the absence of other errors - so there may be more.
  def assert_has_errors(record, errors)
    errors.each do |field, field_errors|
      Array(field_errors).each do |error|
        assert_includes record.errors[field], error
      end
    end
  end

  def user_attributes(attrs = {})
    FactoryGirl.attributes_for :user, attrs
  end

end
