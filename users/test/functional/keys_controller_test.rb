require 'test_helper'

class KeysControllerTest < ActionController::TestCase

  test "get existing public key" do
    public_key = 'my public key'
    @user = stub_record :user, :public_key => public_key
    User.stubs(:find_by_login).with(@user.login).returns(@user)
    get :show, :login => @user.login
    assert_response :success
    assert_equal "text/html", response.content_type
    assert_equal public_key, response.body
  end

  test "get non-existing public key for user" do
    @user = stub_record :user
    User.stubs(:find_by_login).with(@user.login).returns(@user)
    get :show, :login => @user.login
    assert_response :success
    assert_equal "text/html", response.content_type
    assert_equal '', response.body.strip
  end

  test "get public key for non-existing user" do
    get :show, :login => 'asdkljslksjfdlskfj'
    assert_response :success
    assert_equal "text/html", response.content_type
    assert_equal '', response.body.strip
  end

end
