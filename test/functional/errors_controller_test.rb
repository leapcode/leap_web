class ErrorsControllerTest < ActionController::TestCase

  def test_not_found_resonds_with_404
    get 'not_found'
    assert_response 404
    assert_template 'errors/not_found'
  end

  def test_server_error_resonds_with_500
    get 'server_error'
    assert_response 500
    assert_template 'errors/server_error'
  end
end
