#
# tests for authenticating an admin or monitor user
# via static configured tokens.
#

require 'test_helper'

class Api::TokenAuthTest < ApiControllerTest
  tests Api::ServicesController

  def test_login_via_api_token
    with_config(:allow_anonymous_certs => false) do
      monitor_auth do
        api_get :show
        assert assigns(:token), 'should have authenticated via api token'
        assert assigns(:token).is_a? ApiToken
        assert @controller.send(:current_user).is_a? ApiMonitorUser
      end
    end
  end

  def test_fail_api_auth_when_ip_not_allowed
    with_config(:allow_anonymous_certs => false) do
      allowed = "99.99.99.99"
      new_config = {api_tokens: APP_CONFIG["api_tokens"].merge(allowed_ips: [allowed])}
      with_config(new_config) do
        monitor_auth do
          request.env['REMOTE_ADDR'] = "1.1.1.1"
          api_get :show
          assert_nil assigns(:token), "should not be able to auth with api token when ip restriction doesn't allow it"
          request.env['REMOTE_ADDR'] = allowed
          api_get :show
          assert assigns(:token), "should have authenticated via api token"
        end
      end
    end
  end

end

