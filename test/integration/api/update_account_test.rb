require 'test_helper'
require_relative 'srp_test'

class UpdateAccountTest < SrpTest

  setup do
    register_user
  end

  test "require authentication" do
    update_user password: "No! Verify me instead."
    assert_access_denied
  end

  test "require token" do
    authenticate
    put "http://api.lvh.me:3000/1/users/" + @user.id + '.json',
      user_params(password: "No! Verify me instead.")
    assert_access_denied
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
    authenticate
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
