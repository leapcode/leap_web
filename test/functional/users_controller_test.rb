require 'test_helper'

class UsersControllerTest < ActionController::TestCase

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

  test "failed show without login" do
    user = find_record :user
    get :show, :id => user.id
    assert_response :redirect
    assert_redirected_to login_path
  end

  test "user can see user" do
    user = find_record :user,
      :most_recent_tickets => []
    login user
    get :show, :id => user.id
    assert_response :success
  end

  test "admin can see other user" do
    user = find_record :user,
      :most_recent_tickets => []
    login :is_admin? => true
    get :show, :id => user.id
    assert_response :success

  end

  test "user cannot see other user" do
    user = find_record :user,
      :most_recent_tickets => []
    login
    get :show, :id => user.id
    assert_response :redirect
    assert_access_denied
  end

  test "may not show non-existing user without auth" do
    nonid = 'thisisnotanexistinguserid'

    get :show, :id => nonid
    assert_access_denied(true, false)
  end

  test "may not show non-existing user without admin" do
    nonid = 'thisisnotanexistinguserid'
    login

    get :show, :id => nonid
    assert_access_denied
  end

  test "redirect admin to user list for non-existing user" do
    nonid = 'thisisnotanexistinguserid'
    login :is_admin? => true
    get :show, :id => nonid
    assert_response :redirect
    assert_equal({:alert => "No such user."}, flash.to_hash)
    assert_redirected_to users_path
  end

  test "should get edit view" do
    user = find_record :user

    login user
    get :edit, :id => user.id

    assert_equal user, assigns[:user]
  end

  test "admin can destroy user" do
    user = find_record :user

    # we destroy the user record and the associated data...
    user.expects(:destroy)
    Identity.expects(:disable_all_for).with(user)
    Ticket.expects(:destroy_all_from).with(user)

    login :is_admin? => true
    delete :destroy, :id => user.id

    assert_response :redirect
    assert_redirected_to users_path
  end

  test "user can cancel account" do
    user = find_record :user

    # we destroy the user record and the associated data...
    user.expects(:destroy)
    Identity.expects(:disable_all_for).with(user)
    Ticket.expects(:destroy_all_from).with(user)

    login user
    expect_logout
    delete :destroy, :id => @current_user.id

    assert_response :redirect
    assert_redirected_to bye_url
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

  test "admin can search users" do
    login :is_admin? => true
    get :index, :query => "a"

    assert_response :success
    assert assigns(:users)
  end

  test "user cannot enable own account" do
    user = find_record :user
    login
    post :enable, :id => user.id
    assert_access_denied
  end

  test "admin can deactivate user" do
    user = find_record :user
    assert user.enabled?
    user.expects(:save).returns(true)

    login :is_admin? => true

    post :deactivate, :id => user.id
    assert !assigns(:user).enabled?
  end

end
