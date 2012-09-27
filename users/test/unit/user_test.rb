require 'test_helper'

class UserTest < ActiveSupport::TestCase

  include SRP::Util
  test "test set of attributes should be valid" do
    user = User.new(User.valid_attributes_hash)
    assert user.valid?
  end

  test "find_by_param gets User by login" do
    user = User.create!(User.valid_attributes_hash)
    assert_equal user, User.find_by_param(user.login)
    user.destroy
  end

  test "to_param gives user login" do
    user = User.new(User.valid_attributes_hash)
    assert_equal user.login, user.to_param
  end

  test "verifier returns number for the hex in password_verifier" do
    user = User.new(User.valid_attributes_hash)
    assert_equal user.password_verifier.hex, user.verifier
  end

  test "salt returns number for the hex in password_salt" do
    user = User.new(User.valid_attributes_hash)
    assert_equal user.password_salt.hex, user.salt
  end

  test "should include SRP::Authentication" do
    client_rnd = bigrand(32).hex
    user = User.new(User.valid_attributes_hash)
    srp_session = user.initialize_auth(client_rnd)
    assert srp_session.is_a? SRP::Authentication::Session
    assert_equal client_rnd, srp_session.aa
  end

end
