require 'test_helper'

class V1::UsersControllerTest < ActionController::TestCase

  test "user can change settings" do
    user = find_record :user
    changed_attribs = record_attributes_for :user_with_settings
    account_settings = stub
    account_settings.expects(:update).with(changed_attribs)
    AccountSettings.expects(:new).with(user).returns(account_settings)

    login user
    put :update, :user => changed_attribs, :id => user.id, :format => :json

    assert_equal user, assigns[:user]
    assert_response 204
    assert_equal " ", @response.body
  end

  test "admin can update user" do
    user = find_record :user
    changed_attribs = record_attributes_for :user_with_settings
    account_settings = stub
    account_settings.expects(:update).with(changed_attribs)
    AccountSettings.expects(:new).with(user).returns(account_settings)

    login :is_admin? => true
    put :update, :user => changed_attribs, :id => user.id, :format => :json

    assert_equal user, assigns[:user]
    assert_response 204
  end

  test "user cannot update other user" do
    user = find_record :user
    login
    put :update, :user => record_attributes_for(:user_with_settings), :id => user.id, :format => :json
    assert_access_denied
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

  test "admin can autocomplete users" do
    login :is_admin? => true
    get :index, :query => 'a', :format => :json

    assert_response :success
    assert assigns(:users)
  end

end
