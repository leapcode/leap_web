require_relative '../test_helper'

class IdentityTest < ActiveSupport::TestCase
  include StubRecordHelper
  include RecordAssertions

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
    assert_error @id, destination: :blank
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
    assert_error dup, destination: :taken
  end

  test "validates availability" do
    other_user = find_record :user
    @id = Identity.create_for @user, address: alias_name, destination: forward_address
    taken = Identity.build_for other_user, address: alias_name
    assert !taken.valid?
    assert_error taken, address: :taken
  end

  test "setting and getting pgp key" do
    @id = Identity.for(@user)
    @id.set_key(:pgp, pgp_key_string)
    assert_equal pgp_key_string, @id.keys[:pgp]
  end

  test "deleting pgp key" do
    @id = Identity.for(@user)
    @id.set_key(:pgp, pgp_key_string)
    @id.delete_key(:pgp)
    assert_nil @id.keys[:pgp]
    assert_equal Hash.new, @id.keys
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

  test "disable identity" do
    @id = Identity.for(@user)
    @id.disable!
    assert !@id.enabled?
    assert @id.valid?
  end

  test "orphan identity" do
    @id = Identity.for(@user)
    @id.orphan!
    assert_equal @user.email_address, @id.address
    assert_nil @id.destination
    assert_nil @id.user
    assert @id.orphaned?
    assert @id.valid?
  end

  test "orphaned identity blocks handle" do
    @id = Identity.for(@user)
    @id.orphan!
    other_user = find_record :user
    taken = Identity.build_for other_user, address: @id.address
    assert !taken.valid?
    assert_error taken, address: :taken
  end

  test "destroy all orphaned identities" do
    @id = Identity.for(@user)
    @id.orphan!
    assert Identity.orphaned.count > 0
    Identity.destroy_all_orphaned
    assert_equal 0, Identity.orphaned.count
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
    # make this expire later than the other test identities
    # so that the query that returns certs sorted by expiry will
    # return cert_stub first.
    @cert_stub ||= stub(expiry: 2.month.from_now, fingerprint: SecureRandom.hex)
  end
end
