require 'test_helper'
require_relative 'srp_test'

class TokenTest < SrpTest

  setup do
    register_user
  end

  test "stores token SHA512 encoded" do
    authenticate
    token = server_auth['token']
    assert Token.find(Digest::SHA512.hexdigest(token))
  end
end
