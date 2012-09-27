require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  test "should get new" do
    get :new
    assert_equal User, assigns(:user).class
    assert_response :success
  end

  test "should create new user" do
    params = User.valid_attributes_hash
    user = stub params.merge(:id => 123)
    params.stringify_keys!
    User.expects(:create!).with(params).returns(user)
    post :create, :user => params
    assert_nil session[:user_id]
    assert_response :redirect
    assert_redirected_to root_url
  end

  test "should redirect to signup form on failed attempt" do
    params = User.valid_attributes_hash.slice(:login)
    user = User.new(params)
    params.stringify_keys!
    User.expects(:create!).with(params).raises(VALIDATION_FAILED.new(user))
    post :create, :user => params
    assert_nil session[:user_id]
    assert_equal user, assigns[:user]
    assert_response :redirect
    assert_redirected_to new_user_path
  end

end
