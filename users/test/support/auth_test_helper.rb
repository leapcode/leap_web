module AuthTestHelper

  def assert_access_denied
    assert_equal({:alert => "Not authorized"}, flash.to_hash)
    assert_redirected_to login_path
  end
end
