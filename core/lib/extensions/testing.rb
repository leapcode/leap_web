module LeapWebCore
  module AssertResponses

    # response that works with different TestCases:
    # ActionController::TestCase has @response
    # ActionDispatch::IntegrationTest has @response
    # Rack::Test::Methods defines last_response
    def get_response
      @response || last_response
    end

    def assert_attachement_filename(name)
      assert_equal %Q(attachment; filename="#{name}"),
        get_response.headers["Content-Disposition"]
    end

    def assert_json_response(object)
      if object.is_a? Hash
        object.stringify_keys! if object.respond_to? :stringify_keys!
        assert_equal object, JSON.parse(get_response.body)
      else
        assert_equal object.to_json, get_response.body
      end
    end

    def assert_json_error(object)
      object.stringify_keys! if object.respond_to? :stringify_keys!
      assert_json_response :errors => object
    end
  end
end

class ::ActionController::TestCase
  include LeapWebCore::AssertResponses
end

class ::ActionDispatch::IntegrationTest
  include LeapWebCore::AssertResponses
end
