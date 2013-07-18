require 'test_helper'

class IdentityTest < ActiveSupport::TestCase

  setup do
    @user = FactoryGirl.create(:user)
  end

  teardown do
    @user.destroy
  end

  test "initial identity for a user" do
    id = @user.build_identity
    assert_equal @user.email_address, id.address
    assert_equal @user.email_address, id.destination
    assert_equal @user, id.user
  end

  test "add alias" do
    id = @user.build_identity address: alias_name
    assert_equal LocalEmail.new(alias_name), id.address
    assert_equal @user.email_address, id.destination
    assert_equal @user, id.user
  end

  test "add forward" do
    id = @user.build_identity destination: forward_address
    assert_equal @user.email_address, id.address
    assert_equal Email.new(forward_address), id.destination
    assert_equal @user, id.user
  end

  test "forward alias" do
    id = @user.build_identity address: alias_name, destination: forward_address
    assert_equal LocalEmail.new(alias_name), id.address
    assert_equal Email.new(forward_address), id.destination
    assert_equal @user, id.user
    id.save
  end

  def alias_name
    @alias_name ||= Faker::Internet.user_name
  end

  def forward_address
    @forward_address ||= Faker::Internet.email
  end
end
