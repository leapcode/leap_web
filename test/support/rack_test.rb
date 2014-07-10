require_relative 'assert_responses'

class RackTest < ActiveSupport::TestCase
  include Rack::Test::Methods
  include Warden::Test::Helpers

  CONFIG_RU = (Rails.root + 'config.ru').to_s
  OUTER_APP = Rack::Builder.parse_file(CONFIG_RU).first

  def app
    OUTER_APP
  end

  def assert_access_denied
    assert_json_response('error' => I18n.t(:not_authorized))
    assert_response :forbidden
  end

  def assert_login_required
    assert_json_response('error' => I18n.t(:not_authorized_login))
    assert_response :unauthorized
  end

  # inspired by rails 4
  # -> actionpack/lib/action_dispatch/testing/assertions/response.rb
  def assert_response(type, message = nil)
    # RackTest does not know @response
    response_code = last_response.status
    message ||= "Expected response to be a <#{type}>, but was <#{response_code}>"

    if Symbol === type
      if [:success, :missing, :redirect, :error].include?(type)
        assert last_response.send("#{type}?"), message
      else
        code = Rack::Utils::SYMBOL_TO_STATUS_CODE[type]
        assert_equal code, response_code, message
      end
    else
      assert_equal type, response_code, message
    end
  end

end
