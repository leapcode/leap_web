require_relative '../test_helper'

class ApiTokenTest < ActiveSupport::TestCase

  setup do
  end

  test "api token only authenticates ApiUser" do
    token_string = APP_CONFIG['api_tokens']['monitor']
    assert !token_string.nil?, 'monitor token should be configured'
    assert !token_string.empty?
    token = ApiToken.find_by_token(token_string)
    user = token.authenticate
    assert user, 'api token should authenticate'
    assert user.is_a?(ApiUser), 'api token should return api user'
    assert user.is_monitor?, 'api monitor token should return monitor user'
    assert !user.is_admin?, 'api monitor token should not return admin user'
  end

  test "invalid api tokens can't authenticate" do
    assert_nil ApiToken.find_by_token("not a token")
    with_config({"api_tokens" => {"test" => ""}}) do
      assert_equal "", APP_CONFIG['api_tokens']['test']
      assert_nil ApiToken.find_by_token("")
    end
  end

end