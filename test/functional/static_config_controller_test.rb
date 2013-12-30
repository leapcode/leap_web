require 'test_helper'

# use minitest for stubbing, rather than bloated mocha
require 'minitest/stub_const'

class StaticConfigControllerTest < ActionController::TestCase

  def setup
  end

  def test_provider_success
    StaticConfigController.stub_const(:PROVIDER_JSON, file_path('provider.json')) do
      get :provider, format: :json
      assert_equal 'application/json', @response.content_type
      assert_response :success
    end
  end

  def test_provider_not_modified
    StaticConfigController.stub_const(:PROVIDER_JSON, file_path('provider.json')) do
      request.env["HTTP_IF_MODIFIED_SINCE"] = File.mtime(file_path('provider.json')).rfc2822()
      get :provider, format: :json
      assert_response 304
    end
  end

end
