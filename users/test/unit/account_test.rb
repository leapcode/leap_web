require 'test_helper'

class AccountTest < ActiveSupport::TestCase

  test "create a new account" do
    user = Account.create(FactoryGirl.attributes_for(:user))
    assert user.valid?
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
        user = Account.create(FactoryGirl.attributes_for(:user))
        user.account.destroy
      end
    end
  end

  test "change username and create alias" do
    user = Account.create(FactoryGirl.attributes_for(:user))
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

end
