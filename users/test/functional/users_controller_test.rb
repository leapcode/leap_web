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
    User.expects(:create).with(user.params).returns(user)
    post :create, :user => user.params, :format => :json
    assert_nil session[:user_id]
    assert_json_response user
    assert_response :success
  end

  test "should redirect to signup form on failed attempt" do
    params = User.valid_attributes_hash.slice(:login)
    user = User.new(params)
    params.stringify_keys!
    assert !user.valid?
    User.expects(:create).with(params).returns(user)
    post :create, :user => params, :format => :json
    assert_json_error user.errors.messages
    assert_response 422
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
    put :update, :user => user.params, :id => user.id, :format => :json
    assert_equal user, assigns[:user]
    assert_equal " ", @response.body
    assert_response 204
  end
end
