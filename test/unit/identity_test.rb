require 'test_helper'

class IdentityTest < ActiveSupport::TestCase
  include StubRecordHelper

  setup do
    @user = find_record :user
  end

  teardown do
    if @id && @id.persisted?
      id = Identity.find(@id.id)
      id.destroy if id.present?
    end
  end

  test "blank identity does not crash on valid?" do
    @id = Identity.new
    assert !@id.valid?
  end

  test "enabled identity requires destination" do
    @id = Identity.new user: @user, address: @user.email_address
    assert !@id.valid?
    assert_equal ["can't be blank"], @id.errors[:destination]
  end

  test "disabled identity requires no destination" do
    @id = Identity.new address: @user.email_address
    assert @id.valid?
  end

  test "initial identity for a user" do
    @id = Identity.for(@user)
    assert_equal @user.email_address, @id.address
    assert_equal @user.email_address, @id.destination
    assert_equal @user, @id.user
  end

  test "add alias" do
    @id = Identity.for @user, address: alias_name
    assert_equal LocalEmail.new(alias_name), @id.address
    assert_equal @user.email_address, @id.destination
    assert_equal @user, @id.user
  end

  test "add forward" do
    @id = Identity.for @user, destination: forward_address
    assert_equal @user.email_address, @id.address
    assert_equal Email.new(forward_address), @id.destination
    assert_equal @user, @id.user
  end

  test "forward alias" do
    @id = Identity.for @user, address: alias_name, destination: forward_address
    assert_equal LocalEmail.new(alias_name), @id.address
    assert_equal Email.new(forward_address), @id.destination
    assert_equal @user, @id.user
  end

  test "prevents duplicates" do
    @id = Identity.create_for @user, address: alias_name, destination: forward_address
    dup = Identity.build_for @user, address: alias_name, destination: forward_address
    assert !dup.valid?
    assert_equal ["has already been taken"], dup.errors[:destination]
  end

  test "validates availability" do
    other_user = find_record :user
    @id = Identity.create_for @user, address: alias_name, destination: forward_address
    taken = Identity.build_for other_user, address: alias_name
    assert !taken.valid?
    assert_equal ["has already been taken"], taken.errors[:address]
  end

  test "setting and getting pgp key" do
    @id = Identity.for(@user)
    @id.set_key(:pgp, pgp_key_string)
    assert_equal pgp_key_string, @id.keys[:pgp]
  end

  test "querying pgp key via couch" do
    @id = Identity.for(@user)
    @id.set_key(:pgp, pgp_key_string)
    @id.save
    view = Identity.pgp_key_by_email.key(@id.address)
    assert_equal 1, view.rows.count
    assert result = view.rows.first
    assert_equal @id.address, result["key"]
    assert_equal @id.keys[:pgp], result["value"]
  end

  test "fail to add non-local email address as identity address" do
    @id = Identity.for @user, address: forward_address
    assert !@id.valid?
    assert_match /needs to end in/, @id.errors[:address].first
  end

  test "alias must meet same conditions as login" do
    @id = Identity.create_for @user, address: alias_name.capitalize
    assert !@id.valid?
    #hacky way to do this, but okay for now:
    assert @id.errors.messages.flatten(2).include? "Must begin with a lowercase letter"
    assert @id.errors.messages.flatten(2).include? "Only lowercase letters, digits, . - and _ allowed."
  end

  test "destination must be valid email address" do
    @id = Identity.create_for @user, address: @user.email_address, destination: 'ASKJDLFJD'
    assert !@id.valid?
    assert @id.errors.messages[:destination].include? "needs to be a valid email address"
  end

  test "disabled identity" do
    @id = Identity.for(@user)
    @id.disable
    assert_equal @user.email_address, @id.address
    assert_equal nil, @id.destination
    assert_equal nil, @id.user
    assert !@id.enabled?
    assert @id.valid?
  end

  test "disabled identity blocks handle" do
    @id = Identity.for(@user)
    @id.disable
    @id.save
    other_user = find_record :user
    taken = Identity.build_for other_user, address: @id.address
    assert !taken.valid?
    assert_equal ["has already been taken"], taken.errors[:address]
  end

  test "destroy all disabled identities" do
    @id = Identity.for(@user)
    @id.disable
    @id.save
    assert Identity.disabled.count > 0
    Identity.destroy_all_disabled
    assert_equal 0, Identity.disabled.count
  end

  test "store cert fingerprint" do
    @id = Identity.for(@user)
    @id.register_cert cert_stub
    entry = {cert_stub.fingerprint => cert_stub.expiry.to_date.to_s}
    assert_equal entry, @id.cert_fingerprints
  end

  test "query cert fingerprints by expiry" do
    @id = Identity.for(@user)
    @id.register_cert cert_stub
    @id.save
    row = Identity.cert_fingerprints_by_expiry.descending.rows.first
    assert_equal row['key'], cert_stub.expiry.to_date.to_s
    assert_equal row['value'], cert_stub.fingerprint
  end

  test "query cert expiry for a cert fingerprint" do
    @id = Identity.for(@user)
    @id.register_cert cert_stub
    @id.save
    row = Identity.cert_expiry_by_fingerprint.key(cert_stub.fingerprint).rows.first
    assert_equal row['key'], cert_stub.fingerprint
    assert_equal row['value'], cert_stub.expiry.to_date.to_s
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

  def cert_stub
    # make this expire later than the others so it's on top
    # when sorting by expiry descending.
    @cert_stub ||= stub expiry: 2.month.from_now,
    fingerprint: SecureRandom.hex
  end
end
