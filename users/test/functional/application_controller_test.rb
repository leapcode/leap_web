require 'test_helper'

class ApplicationControllerTest < ActionController::TestCase

  def setup
    # so we can test the effect on the response
    @controller.response = @response
  end

  def test_require_login_redirect
    @controller.send(:require_login)
    assert_access_denied(true, false)
  end

  def test_require_login
    login
    @controller.send(:require_login)
    assert_access_denied(false)
  end

  def test_require_admin
    login
    @current_user.expects(:is_admin?).returns(false)
    @controller.send(:require_admin)
    assert_access_denied
  end

end
