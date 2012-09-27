module LeapWebCore
  module AssertResponses

    def assert_attachement_filename(name)
      assert_equal %Q(attachment; filename="#{name}"),
        @response.headers["Content-Disposition"]
    end


    def assert_json_response(object)
      object.stringify_keys! if object.respond_to? :stringify_keys!
      assert_equal object, JSON.parse(@response.body)
    end

  end
end

class ::ActionController::TestCase
  include LeapWebCore::AssertResponses
end

class ::ActionDispatch::IntegrationTest
  include LeapWebCore::AssertResponses
end
