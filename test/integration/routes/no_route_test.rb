require 'test_helper'

class NoRouteTest < ActionDispatch::IntegrationTest

  def test_path_with_dot
    assert_no_route '.viminfo'
  end

  def assert_no_route(path, options = {})
    options[:method] ||= :get
    path = "/#{path}" unless path.first == "/"
    params = @routes.recognize_path(path, method: :get)
    flunk "Expected no route to '#{path}' but found: #{params.inspect}"
  rescue ActionController::RoutingError
    pass
  end
end
