require 'test_helper'

class ErrorHandlingTest < ActionController::TestCase
  tests HomeController

  def setup
    HomeController.any_instance.stubs(:index).raises
  end

  def test_json_error
    get :index, format: :json
    assert_equal 'application/json', @response.content_type
    assert json = JSON.parse(@response.body)
    assert_equal ['error'], json.keys
  end

  def test_html_error_reraises
    assert_raises RuntimeError do
      get :index
    end
  end
end
