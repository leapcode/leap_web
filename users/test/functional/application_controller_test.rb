require 'test_helper'

class ApplicationControllerTest < ActionController::TestCase

  def setup
    # so we can test the effect on the response
    @controller.response = @response
  end

  def test_authorize_redirect
    stub_logged_out
    @controller.send(:authorize)
    assert_access_denied
  end

  def test_current_user_with_caching
    @user = stub_logged_in
    assert_equal @user, @controller.send(:current_user)
    assert_equal @user, @controller.send(:current_user) # tests caching
  end

  def test_authorized
    @user = stub_logged_in
    @controller.send(:authorize)
    assert_access_denied(false)
  end

  def test_admin
    bool = stub
    @user = stub_logged_in
    @user.expects(:is_admin?).returns(bool)
    assert_equal bool, @controller.send(:admin?)
  end

  def test_authorize_admin
    @user = stub_logged_in
    @user.expects(:is_admin?).returns(false)
    @controller.send(:authorize_admin)
    assert_access_denied
  end

end
