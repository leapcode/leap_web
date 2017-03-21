require 'test_helper'

class KeysControllerTest < ActionController::TestCase

  test "get key for username with dot" do
    assert_routing 'key/username.with.dot', controller: 'keys',
      action: 'show',
      login: 'username.with.dot',
      format: :text
  end

  test "get existing public key" do
    public_key = 'my public key'
    @user = stub_record :user, :public_key => public_key
    User.stubs(:find_by_login).with(@user.login).returns(@user)
    get :show, :login => @user.login
    assert_response :success
    assert_equal "text/text", response.content_type
    assert_equal public_key, response.body
  end

  test "get non-existing public key for user" do
    # this isn't a scenerio that should generally occur.
    @user = stub_record :user
    User.stubs(:find_by_login).with(@user.login).returns(@user)
    get :show, :login => @user.login
    assert_response :success
    assert_equal "text/text", response.content_type
    assert_equal '', response.body.strip
  end

  test "get public key for non-existing user" do
    # raise 404 error if user doesn't exist
    get :show, :login => 'asdkljslksjfdlskfj'
    assert_response :not_found
  end

end
