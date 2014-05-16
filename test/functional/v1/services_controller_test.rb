require 'test_helper'

class V1::ServicesControllerTest < ActionController::TestCase

  test "anonymous user gets login required service info" do
    get :show, format: :json
    assert_json_response name: 'anonymous',
      eip_rate_limit: false,
      description: 'please login to access our services'
  end

  test "anonymous user gets vpn service info" do
    with_config allow_anonymous_certs: true do
      get :show, format: :json
      assert_json_response name: 'anonymous',
        eip_rate_limit: false,
        description: 'anonymous access to the VPN'
    end
  end

  test "user can see their service info" do
    login
    get :show, format: :json
    default_level = APP_CONFIG[:default_service_level]
    assert_json_response APP_CONFIG[:service_levels][default_level]
  end

end

