require 'test_helper'

class IdentityTest < ActiveSupport::TestCase

  setup do
    @user = FactoryGirl.create(:user)
  end

  test "user has identity to start with" do
    id = @user.build_identity
    assert_equal @user.email_address, id.address
    assert_equal @user.email_address, id.destination
    assert_equal @user, id.user
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
