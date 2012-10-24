#
# Testing and documenting the helper methods available from
# ApplicationController
#

require 'test_helper'

class HelperMethodsTest < ActionController::TestCase
  tests ApplicationController

  # we test them right in here...
  include ApplicationController._helpers

  # they all reference the controller.
  def controller
    @controller
  end

  def setup
    @user_id = stub
    @user = stub
    session[:user_id] = @user_id
  end

  def test_current_user_with_caching
    User.expects(:find).once.with(@user_id).returns(@user)
    assert_equal @user, current_user
    assert_equal @user, current_user # tests caching
  end

  def test_logged_in
    User.expects(:find).once.with(@user_id).returns(@user)
    assert logged_in?
  end

  def test_logged_in
    User.expects(:find).once.with(@user_id).returns(nil)
    assert !logged_in?
  end

  def test_admin
    bool = stub
    User.expects(:find).once.with(@user_id).returns(@user)
    @user.expects(:is_admin?).returns(bool)
    assert_equal bool, admin?
  end

end
