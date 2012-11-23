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

  test "should get edit view" do
    params = User.valid_attributes_hash
    user = stub params.merge(:id => 123, :class => User, :to_key => ['123'], :new_record? => false, :persisted? => :true)
    login user
    get :edit, :id => user.id
    assert_equal user, assigns[:user]
  end

  test "should process updated params" do
    params = User.valid_attributes_hash
    user = stub params.merge(:id => 123)
    params.stringify_keys!
    user.expects(:update).with(params).returns(user)
    login user
    post :update, :user => params, :id => user.id
    assert_equal user, assigns[:user]
    assert_response :redirect
    assert_redirected_to edit_user_path(user)
  end

  test "should validate updated params" do
    params = User.valid_attributes_hash
    user = stub params.merge(:id => 123)
    params.stringify_keys!
    user.expects(:update).with(params).returns(user)
    login user
    post :update, :user => params, :id => user.id
    assert_equal user, assigns[:user]
  end


end
