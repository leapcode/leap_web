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

  test "prevents duplicates" do
    id = @user.create_identity address: alias_name, destination: forward_address
    dup = @user.build_identity address: alias_name, destination: forward_address
    assert !dup.valid?
    assert_equal ["This alias already exists"], dup.errors[:base]
  end

  test "validates availability" do
    other_user = FactoryGirl.create(:user)
    id = @user.create_identity address: alias_name, destination: forward_address
    taken = other_user.build_identity address: alias_name
    assert !taken.valid?
    assert_equal ["This email has already been taken"], taken.errors[:base]
    other_user.destroy
  end



  def alias_name
    @alias_name ||= Faker::Internet.user_name
  end

  def forward_address
    @forward_address ||= Faker::Internet.email
  end
end
