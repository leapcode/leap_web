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

  def test_current_user
    login
    assert_equal @current_user, current_user
  end

  def test_logged_in
    login
    assert logged_in?
  end

  def test_logged_out
    assert !logged_in?
  end

  def test_admin
    login
    @current_user.expects(:is_admin?).returns(bool = stub)
    assert_equal bool, admin?
  end

end
