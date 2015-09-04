require 'test_helper'

class AccountTest < ActiveSupport::TestCase

  setup do
    @testcode = InviteCode.new
    @testcode.save!
  end

  teardown do
    Identity.destroy_all_disabled
  end

  test "create a new account" do
    user = Account.create(FactoryGirl.attributes_for(:user, :invite_code => @testcode.invite_code))
    assert user.valid?, "unexpected errors: #{user.errors.inspect}"
    assert user.persisted?
    assert id = user.identity
    assert_equal user.email_address, id.address
    assert_equal user.email_address, id.destination
    user.account.destroy
  end

  test "create and remove a user account" do
    # We keep an identity that will block the handle from being reused.
    assert_difference "Identity.count" do
      assert_no_difference "User.count" do
        user = Account.create(FactoryGirl.attributes_for(:user, :invite_code => @testcode.invite_code))
        user.account.destroy
      end
    end
  end

  test "change username and create alias" do
    user = Account.create(FactoryGirl.attributes_for(:user, :invite_code => @testcode.invite_code))
    old_id = user.identity
    old_email = user.email_address
    user.account.update(FactoryGirl.attributes_for(:user))
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

  test "Invite code count goes up by 1 when the invite code is entered" do

    user = Account.create(FactoryGirl.attributes_for(:user, :invite_code => @testcode.invite_code))
    user_code = InviteCode.find_by_invite_code user.invite_code
    user_code.save
    user.save
    assert user.persisted?
    assert_equal 1, user_code.invite_count

  end

  test "Invite code stays zero when invite code is not used" do
    #user = Account.create(FactoryGirl.attributes_for(:user, :invite_code => @testcode.invite_code))
    invalid_user = FactoryGirl.build(:user, :invite_code => @testcode.invite_code)
    invalid_user.save
    user_code = InviteCode.find_by_invite_code invalid_user.invite_code
    user_code.save

    assert_equal 0, user_code.invite_count
  end
end
