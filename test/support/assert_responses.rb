module AssertResponses

  # response that works with different TestCases:
  # ActionController::TestCase has @response
  # ActionDispatch::IntegrationTest has @response
  # Rack::Test::Methods defines last_response
  def get_response
    @response || last_response
  end

  def content_type
    get_response.content_type.to_s.split(';').first
  end

  def json_response
    return nil unless content_type == 'application/json'
    response = JSON.parse(get_response.body)
    response.respond_to?(:with_indifferent_access) ?
      response.with_indifferent_access :
      response
  end

  def assert_text_response(body = nil)
    assert_equal 'text/plain', content_type
    unless body.nil?
      assert_equal body, get_response.body
    end
  end

  def assert_json_response(object)
    assert_equal 'application/json', content_type
    if object.is_a? Hash
      object.stringify_keys! if object.respond_to? :stringify_keys!
      assert_equal object, json_response
    else
      assert_equal object.to_json, get_response.body
    end
  end

  def assert_json_error(object)
    object.stringify_keys! if object.respond_to? :stringify_keys!
    assert_json_response :errors => object
  end

  # checks for the presence of a key in a json response
  # or a string in a text response
  def assert_response_includes(string_or_key)
    response = json_response || get_response.body
    assert response.include?(string_or_key),
      "response should have included #{string_or_key}"
  end

  def assert_attachement_filename(name)
    assert_equal %Q(attachment; filename="#{name}"),
      get_response.headers["Content-Disposition"]
  end

  def assert_login_required
    assert_error_response :not_authorized_login, :unauthorized
  end

  def assert_access_denied
    assert_error_response :not_authorized, :forbidden
  end

  def assert_error_response(key, status=nil)
    message = I18n.t(key)
    if content_type == 'application/json'
      status ||= :unprocessable_entity
      assert_json_response('error' => key.to_s, 'message' => message)
      assert_response status
    else
      assert_equal({:alert => message}, flash.to_hash)
    end
  end

end

class ::ActionController::TestCase
  include AssertResponses
end

class ::ActionDispatch::IntegrationTest
  include AssertResponses
end
