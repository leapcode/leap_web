require 'test_helper'

class ApplicationControllerTest < ActionController::TestCase

  def setup
    # so we can test the effect on the response
    @controller.response = @response
  end

  def test_authorize_redirect
    @controller.send(:authorize)
    assert_access_denied(true, false)
  end

  def test_authorized
    login
    @controller.send(:authorize)
    assert_access_denied(false)
  end

  def test_authorize_admin
    login
    @current_user.expects(:is_admin?).returns(false)
    @controller.send(:authorize_admin)
    assert_access_denied
  end

end
