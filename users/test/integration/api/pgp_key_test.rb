require 'test_helper'
require_relative 'srp_test'

class PgpKeyTest < SrpTest

  setup do
    # todo: prepare user and login without doing the srp dance
    register_user
    authenticate
  end

  test "upload pgp key" do
    update_user public_key: key
    assert_equal key, Identity.for(@user).keys[:pgp]
  end

  # eventually probably want to remove most of this into a non-integration
  # functional test
  test "prevent uploading invalid key" do
    update_user public_key: "invalid key"
    assert_nil Identity.for(@user).keys[:pgp]
  end

  test "prevent emptying public key" do
    update_user public_key: key
    update_user public_key: ""
    assert_equal key, Identity.for(@user).keys[:pgp]
  end

  protected

  def key
    @key ||= FactoryGirl.build :pgp_key
  end
end
