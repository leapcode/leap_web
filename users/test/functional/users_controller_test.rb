require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  include StubRecordHelper

  test "should get new" do
    get :new
    assert_equal User, assigns(:user).class
    assert_response :success
  end

  test "should create new user" do
    user = stub_record User
    User.expects(:create!).with(user.params).returns(user)
    post :create, :user => user.params
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

  test "should get edit view" do
    user = stub_record User
    User.expects(:find_by_param).with(user.id.to_s).returns(user)
    login user
    get :edit, :id => user.id
    assert_equal user, assigns[:user]
  end

  test "should process updated params" do
    user = stub_record User
    user.expects(:update_attributes).with(user.params).returns(true)
    User.expects(:find_by_param).with(user.id.to_s).returns(user)
    login user
    post :update, :user => user.params, :id => user.id
    assert_equal user, assigns[:user]
    assert_response :redirect
    assert_redirected_to edit_user_path(user)
  end
end
