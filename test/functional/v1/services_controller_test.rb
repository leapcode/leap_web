require 'test_helper'

class V1::ServicesControllerTest < ActionController::TestCase

  test "anonymous user can request service info" do
    get :show, format: :json
    assert_json_response name: 'anonymous',
      cert_prefix: 'LIMITED',
      description: 'anonymous account, with rate limited VPN'
  end

  test "user can see their service info" do
    login
    get :show, format: :json
    assert_json_response name: 'free',
      cert_prefix: 'LIMITED',
      description: 'free account, with rate limited VPN',
      cost: 0,
      quota: 100
  end

end

