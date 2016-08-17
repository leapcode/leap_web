require 'test_helper'

class HomeControllerTest < ActionController::TestCase

  def test_renders_okay
    get :index
    assert_response :success
  end

  def test_other_formats_trigger_406
    assert_raises ActionController::UnknownFormat do
      get :index, format: :xml
    end
  end

end
