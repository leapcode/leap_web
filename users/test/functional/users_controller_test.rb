require 'test_helper'

class UsersControllerTest < ActionController::TestCase

  test "should get new" do
    get :new

    assert_equal User, assigns(:user).class
    assert_response :success
  end

  test "failed show without login" do
    user = FactoryGirl.build(:user)
    user.save
    get :show, :id => user.id
    assert_response :redirect
    assert_redirected_to login_path
    user.destroy
  end

  test "user can see user" do
    user = find_record :user,
      :email => nil,
      :email_forward => nil,
      :email_aliases => [],
      :created_at => Time.now,
      :updated_at => Time.now,
      :most_recent_tickets => []
    login user
    get :show, :id => user.id
    assert_response :success
  end

  test "admin can see other user" do
    user = find_record :user,
      :email => nil,
      :email_forward => nil,
      :email_aliases => [],
      :created_at => Time.now,
      :updated_at => Time.now,
      :most_recent_tickets => []
    login :is_admin? => true
    get :show, :id => user.id
    assert_response :success

  end

  test "user cannot see other user" do
    user = find_record :user,
      :email => nil,
      :email_forward => nil,
      :email_aliases => [],
      :created_at => Time.now,
      :updated_at => Time.now,
      :most_recent_tickets => []
    login
    get :show, :id => user.id
    assert_response :redirect
    assert_access_denied
  end

  test "show for non-existing user" do
    nonid = 'thisisnotanexistinguserid'

    # when unauthenticated:
    get :show, :id => nonid
    assert_access_denied(true, false)

    # when authenticated but not admin:
    login
    get :show, :id => nonid
    assert_access_denied

    # when authenticated as admin:
    # TODO: THIS IS failing to login and have admin? return true in users_controller. Will look into it later.
    login :is_admin => true
    get :show, :id => nonid
    assert_response :redirect
    assert_equal({:alert => "No such user."}, flash.to_hash)
    assert_redirected_to users_path
  end

  test "should create new user" do
    user_attribs = record_attributes_for :user
    user = User.new(user_attribs)
    User.expects(:create).with(user_attribs).returns(user)


    post :create, :user => user_attribs, :format => :json


    assert_nil session[:user_id]
    assert_json_response user
    assert_response :success
  end

  test "should redirect to signup form on failed attempt" do
    user_attribs = record_attributes_for :user
    user_attribs.slice!('login')
    user = User.new(user_attribs)
    assert !user.valid?
    User.expects(:create).with(user_attribs).returns(user)

    post :create, :user => user_attribs, :format => :json

    assert_json_error user.errors.messages
    assert_response 422
  end

  test "should get edit view" do
    user = find_record :user

    login user
    get :edit, :id => user.id

    assert_equal user, assigns[:user]
  end

  test "user can change settings" do
    user = find_record :user
    changed_attribs = record_attributes_for :user_with_settings
    user.expects(:attributes=).with(changed_attribs)
    user.expects(:changed?).returns(true)
    user.expects(:save).returns(true)

    login user
    put :update, :user => changed_attribs, :id => user.id, :format => :json

    assert_equal user, assigns[:user]
    assert_response 204
    assert_equal " ", @response.body
  end

  test "admin can update user" do
    user = find_record :user
    changed_attribs = record_attributes_for :user_with_settings
    user.expects(:attributes=).with(changed_attribs.stringify_keys)
    user.expects(:changed?).returns(true)
    user.expects(:save).returns(true)
    user.stubs(:email_aliases).returns([])

    login :is_admin? => true
    put :update, :user => changed_attribs, :id => user.id, :format => :json

    assert_equal user, assigns[:user]
    assert_response 204
    assert_equal " ", @response.body
  end

  test "admin can destroy user" do
    user = find_record :user
    user.expects(:destroy)

    login :is_admin? => true
    delete :destroy, :id => user.id

    assert_response :redirect
    assert_redirected_to users_path
  end

  test "user can cancel account" do
    user = find_record :user
    user.expects(:destroy)

    login user
    delete :destroy, :id => @current_user.id

    assert_response :redirect
    assert_redirected_to login_path
  end

  test "non-admin can't destroy user" do
    user = find_record :user

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
