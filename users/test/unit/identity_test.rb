require 'test_helper'

class IdentityTest < ActiveSupport::TestCase

  setup do
    @user = FactoryGirl.create(:user)
  end

  teardown do
    @user.destroy
  end

  test "initial identity for a user" do
    id = @user.identity
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

  test "setting and getting pgp key" do
    id = @user.identity
    id.set_key(:pgp, pgp_key_string)
    assert_equal pgp_key_string, id.keys[:pgp]
  end

  test "querying pgp key via couch" do
    id = @user.identity
    id.set_key(:pgp, pgp_key_string)
    id.save
    view = Identity.pgp_key_by_email.key(id.address)
    assert_equal 1, view.rows.count
    assert result = view.rows.first
    assert_equal id.address, result["key"]
    assert_equal id.keys[:pgp], result["value"]
  end

  def alias_name
    @alias_name ||= Faker::Internet.user_name
  end

  def forward_address
    @forward_address ||= Faker::Internet.email
  end

  def pgp_key_string
    @pgp_key ||= "DUMMY PGP KEY ... "+SecureRandom.base64(4096)
  end
end
