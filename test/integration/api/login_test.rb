require 'test_helper'
require_relative 'srp_test'

class LoginTest < SrpTest

  setup do
    register_user
  end

  test "requires handshake before validation" do
    validate("bla")
    assert_json_error login: I18n.t(:all_strategies_failed)
  end

  test "login with srp" do
    authenticate
    assert_equal ["M2", "id", "token"], server_auth.keys
    assert last_response.successful?
    assert_nil server_auth["errors"]
    assert server_auth["M2"]
  end

  test "wrong password login attempt" do
    authenticate password: "wrong password"
    assert_json_error "base" => "Not a valid username/password combination"
    assert !last_response.successful?
    assert_nil server_auth["M2"]
  end

  test "wrong username login attempt" do
    assert_raises RECORD_NOT_FOUND do
      authenticate login: "wrong login"
    end
    assert_json_error "base" => "Not a valid username/password combination"
    assert !last_response.successful?
    assert_nil server_auth
  end

  test "logout" do
    authenticate
    logout
    assert_equal 204, last_response.status
  end

  test "logout requires token" do
    authenticate
    logout(nil, {})
    assert_login_required
  end
end
