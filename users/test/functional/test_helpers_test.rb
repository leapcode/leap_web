#
# There are a few test helpers for dealing with login etc.
# We test them here and also document their behaviour.
#

require 'test_helper'

class TestHelpersTest < ActionController::TestCase
  tests ApplicationController # testing no controller in particular

  def test_login_stubs_warden
    login
    assert_equal @current_user, request.env['warden'].user
  end

  def test_login_token_authenticates
    login
    assert_equal @current_user, @controller.send(:token_authenticate)
  end

  def test_login_stubs_token
    login
    assert @token
    assert_equal @current_user, @token.authenticate
  end

  def test_login_adds_token_header
    login
    token_present = @controller.authenticate_with_http_token do |token, options|
      assert_equal @token.id, token
    end
    # authenticate_with_http_token just returns nil and does not
    # execute the block if there is no token. So we have to also
    # ensure it was run:
    assert token_present
  end
end

