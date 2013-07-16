require 'test_helper'

class IdentityTest < ActiveSupport::TestCase

  setup do
    @user = FactoryGirl.create(:user)
  end

  test "user has identity to start with" do
    id = Identity.new user_id: @user.id
    id.save
    assert_equal 1, Identity.by_user_id.key(@user.id).count
    identity = Identity.find_by_user_id(@user.id)
    assert_equal @user.email_address, identity.address
    assert_equal @user.email_address, identity.destination
    assert_equal @user, identity.user
  end

  test "add alias" do
    skip
    @user.create_identity address: @alias
  end

  test "add forward" do
    skip
    @user.create_identity destination: @external
  end

  test "forward alias" do
    skip
    @user.create_identity address: @alias, destination: @external
  end

end
