require 'test_helper'
require_relative 'srp_test'

class TmpUserTest < SrpTest

  setup do
    register_user('test_user_'+SecureRandom.hex(5))
  end

  test "login with srp" do
    authenticate
    assert_nil server_auth["errors"]
    assert_nil server_auth["error"]
    assert_equal ["M2", "id", "token"], server_auth.keys
    assert last_response.successful?
    assert server_auth["M2"]
  end

end
