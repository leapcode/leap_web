require 'test_helper'

class IdentityTest < ActiveSupport::TestCase
  include StubRecordHelper

  setup do
    @user = find_record :user
  end

  test "initial identity for a user" do
    id = Identity.for(@user)
    assert_equal @user.email_address, id.address
    assert_equal @user.email_address, id.destination
    assert_equal @user, id.user
  end

  test "add alias" do
    id = Identity.for @user, address: alias_name
    assert_equal LocalEmail.new(alias_name), id.address
    assert_equal @user.email_address, id.destination
    assert_equal @user, id.user
  end

  test "add forward" do
    id = Identity.for @user, destination: forward_address
    assert_equal @user.email_address, id.address
    assert_equal Email.new(forward_address), id.destination
    assert_equal @user, id.user
  end

  test "forward alias" do
    id = Identity.for @user, address: alias_name, destination: forward_address
    assert_equal LocalEmail.new(alias_name), id.address
    assert_equal Email.new(forward_address), id.destination
    assert_equal @user, id.user
  end

  test "prevents duplicates" do
    id = Identity.create_for @user, address: alias_name, destination: forward_address
    dup = Identity.build_for @user, address: alias_name, destination: forward_address
    assert !dup.valid?
    assert_equal ["This alias already exists"], dup.errors[:base]
    id.destroy
  end

  test "validates availability" do
    other_user = find_record :user
    id = Identity.create_for @user, address: alias_name, destination: forward_address
    taken = Identity.build_for other_user, address: alias_name
    assert !taken.valid?
    assert_equal ["This email has already been taken"], taken.errors[:base]
    id.destroy
  end

  test "setting and getting pgp key" do
    id = Identity.for(@user)
    id.set_key(:pgp, pgp_key_string)
    assert_equal pgp_key_string, id.keys[:pgp]
  end

  test "querying pgp key via couch" do
    id = Identity.for(@user)
    id.set_key(:pgp, pgp_key_string)
    id.save
    view = Identity.pgp_key_by_email.key(id.address)
    assert_equal 1, view.rows.count
    assert result = view.rows.first
    assert_equal id.address, result["key"]
    assert_equal id.keys[:pgp], result["value"]
    id.destroy
  end

  test "fail to add non-local email address as identity address" do
    id = Identity.for @user, address: forward_address
    assert !id.valid?
    assert_match /needs to end in/, id.errors[:address].first
  end

  test "alias must meet some conditions as login" do
    id = Identity.create_for @user, address: alias_name.capitalize
    assert !id.valid?
    #hacky way to do this, but okay for now:
    assert id.errors.messages.flatten(2).include? "Must begin with a lowercase letter"
    assert id.errors.messages.flatten(2).include? "Only lowercase letters, digits, . - and _ allowed."
  end

  test "destination must be valid email address" do
    id = Identity.create_for @user, address: @user.email_address, destination: 'ASKJDLFJD'
    assert !id.valid?
    assert id.errors.messages[:destination].include? "needs to be a valid email address"
  end

  test "only lowercase destination" do
    id = Identity.create_for @user, address: @user.email_address, destination: forward_address.capitalize
    assert !id.valid?
    assert id.errors.messages[:destination].include? "letters must be lowercase"
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
