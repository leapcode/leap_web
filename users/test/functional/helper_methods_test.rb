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

  def test_current_user_with_caching
    @user = stub_logged_in
    assert_equal @user, current_user
    assert_equal @user, current_user # tests caching
  end

  def test_logged_in
    @user = stub_logged_in
    assert logged_in?
  end

  def test_logged_out
    stub_logged_out
    assert !logged_in?
  end

  def test_admin
    bool = stub
    @user = stub_logged_in
    @user.expects(:is_admin?).returns(bool)
    assert_equal bool, admin?
  end

end
