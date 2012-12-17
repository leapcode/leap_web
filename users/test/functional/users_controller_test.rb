require 'test_helper'

class UsersControllerTest < ActionController::TestCase

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
    user = find_record User,
      :email => nil,
      :email_forward => nil,
      :email_aliases => []

    login user
    get :edit, :id => user.id

    assert_equal user, assigns[:user]
  end

  test "should process updated params" do
    user = find_record User
    user.expects(:attributes=).with(user.params)
    user.expects(:changed?).returns(true)
    user.expects(:save).returns(true)

    login user
    put :update, :user => user.params, :id => user.id, :format => :json

    assert_equal user, assigns[:user]
    assert_response 204
    assert_equal " ", @response.body
  end

  test "admin can update user" do
    user = find_record User
    user.expects(:attributes=).with(user.params)
    user.expects(:changed?).returns(true)
    user.expects(:save).returns(true)

    login :is_admin? => true
    put :update, :user => user.params, :id => user.id, :format => :json

    assert_equal user, assigns[:user]
    assert_response 204
    assert_equal " ", @response.body
  end

  test "admin can destroy user" do
    user = find_record User
    user.expects(:destroy)

    login :is_admin? => true
    delete :destroy, :id => user.id

    assert_response :redirect
    assert_redirected_to users_path
  end

  test "user can cancel account" do
    user = find_record User
    user.expects(:destroy)

    login user
    delete :destroy, :id => @current_user.id

    assert_response :redirect
    assert_redirected_to login_path
  end

  test "non-admin can't destroy user" do
    user = stub_record User

    login
    delete :destroy, :id => user.id

    assert_access_denied
  end

  test "admin can list users" do
    login :is_admin? => true
    get :index

    assert_response :success
    assert assigns(:users)
  end

  test "non-admin can't list users" do
    login
    get :index

    assert_access_denied
  end

  test "admin can autocomplete users" do
    login :is_admin? => true
    get :index, :format => :json

    assert_response :success
    assert assigns(:users)
  end

  test "admin can search users" do
    login :is_admin? => true
    get :index, :query => "a"

    assert_response :success
    assert assigns(:users)
  end

end
