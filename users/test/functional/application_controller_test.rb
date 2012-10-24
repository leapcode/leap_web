require 'test_helper'

class ApplicationControllerTest < ActionController::TestCase

  def setup
    @user_id = stub
    @user = stub
    session[:user_id] = @user_id
    # so we can test the effect on the response
    @controller.response = @response
  end

  def test_authorize_redirect
    session[:user_id] = nil
    @controller.send(:authorize)
    assert_access_denied
  end

  def test_current_user_with_caching
    User.expects(:find).once.with(@user_id).returns(@user)
    assert_equal @user, @controller.send(:current_user)
    assert_equal @user, @controller.send(:current_user) # tests caching
  end

  def test_authorized
    User.expects(:find).once.with(@user_id).returns(@user)
    @controller.send(:authorize)
  end

  def test_admin
    bool = stub
    User.expects(:find).once.with(@user_id).returns(@user)
    @user.expects(:is_admin?).returns(bool)
    assert_equal bool, @controller.send(:admin?)
  end

  def test_authorize_admin
    User.expects(:find).once.with(@user_id).returns(@user)
    @user.expects(:is_admin?).returns(false)
    @controller.send(:authorize_admin)
    assert_access_denied
  end

end
