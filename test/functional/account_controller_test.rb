require 'test_helper'

class AccountControllerTest < ActionController::TestCase

  test "should get new" do
    get :new
    assert_equal User, assigns(:user).class
    assert_response :success
  end

  test "new should redirect logged in users" do
    login
    get :new
    assert_response :redirect
    assert_redirected_to home_path
  end

  test "new redirects if registration is closed" do
    with_config(allow_registration: false) do
      get :new
      assert_response :redirect
      assert_redirected_to home_path
    end
  end
end

