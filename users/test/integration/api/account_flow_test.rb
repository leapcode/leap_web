require 'test_helper'
require_relative 'srp_test'

class AccountFlowTest < SrpTest

  setup do
    register_user
  end

  test "signup response" do
    assert_json_response :login => @login, :ok => true
    assert last_response.successful?
  end

  test "signup and login with srp via api" do
    authenticate
    assert last_response.successful?
    assert_nil server_auth["errors"]
    assert server_auth["M2"]
  end

  test "signup and wrong password login attempt" do
    authenticate password: "wrong password"
    assert_json_error "base" => "Not a valid username/password combination"
    assert !last_response.successful?
    assert_nil server_auth["M2"]
  end

  test "signup and wrong username login attempt" do
    assert_raises RECORD_NOT_FOUND do
      authenticate login: "wrong login"
    end
    assert_json_error "base" => "Not a valid username/password combination"
    assert !last_response.successful?
    assert_nil server_auth
  end

  test "update password via api" do
    authenticate
    update_user password: "No! Verify me instead."
    authenticate
    assert last_response.successful?
    assert_nil server_auth["errors"]
    assert server_auth["M2"]
  end

  test "change login with password_verifier" do
    authenticate
    new_login = 'zaph'
    cleanup_user new_login
    update_user login: new_login, password: @password
    assert last_response.successful?
    assert_equal new_login, @user.reload.login
  end

  test "prevent changing login without changing password_verifier" do
    authenticate
    original_login = @user.login
    new_login = 'zaph'
    cleanup_user new_login
    update_user login: new_login
    assert last_response.successful?
    # does not change login if no password_verifier is present
    assert_equal original_login, @user.reload.login
  end
end
