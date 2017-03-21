require 'test_helper'

class Api::UsersControllerTest < ApiControllerTest

  test "user can change settings" do
    user = find_record :user
    changed_attribs = record_attributes_for :user_with_settings
    account_settings = stub
    account_settings.expects(:update).with(changed_attribs)
    Account.expects(:new).with(user).returns(account_settings)

    login user
    api_put :update, :user => changed_attribs, :id => user.id, :format => :json

    assert_equal user, assigns[:user]
    assert_response 204
    assert @response.body.blank?, "Response should be blank"
  end

  test "admin can update user" do
    user = find_record :user
    changed_attribs = record_attributes_for :user_with_settings
    account_settings = stub
    account_settings.expects(:update).with(changed_attribs)
    Account.expects(:new).with(user).returns(account_settings)

    login :is_admin? => true
    api_put :update, :user => changed_attribs, :id => user.id, :format => :json

    assert_equal user, assigns[:user]
    assert_response 204
  end

  test "user cannot update other user" do
    user = find_record :user
    login
    api_put :update, id: user.id,
      user: record_attributes_for(:user_with_settings),
      :format => :json
    assert_access_denied
  end

  test "should create new user" do
    user_attribs = record_attributes_for :user
    user = User.new(user_attribs)
    Account.expects(:create).with(user_attribs).returns(user)

    api_post :create, :user => user_attribs, :format => :json

    assert_nil session[:user_id]
    assert_json_response user
    assert_response :success
  end

  test "should redirect to signup form on failed attempt" do
    user_attribs = record_attributes_for :user
    user_attribs.slice!('login')
    user = User.new(user_attribs)
    assert !user.valid?
    Account.expects(:create).with(user_attribs).returns(user)

    api_post :create, :user => user_attribs, :format => :json

    assert_json_error user.errors.messages
    assert_response 422
  end

  test "admin can autocomplete users" do
    login :is_admin? => true
    api_get :index, :query => 'a', :format => :json

    assert_response :success
    assert assigns(:users)
  end

  test "create returns forbidden if registration is closed" do
    user_attribs = record_attributes_for :user
    with_config(allow_registration: false) do
      api_post :create, :user => user_attribs, :format => :json
      assert_response :forbidden
    end
  end

  test "admin can show user" do
    user = FactoryGirl.create :user
    login :is_admin? => true
    api_get :show, :id => 0, :login => user.login, :format => :json
    assert_response :success
    assert_json_response user.to_hash
    api_get :show, :id => user.id, :format => :json
    assert_response :success
    assert_json_response user.to_hash
    api_get :show, :id => "0", :format => :json
    assert_response :not_found
  end

  test "admin can show is_admin property" do
    admin = FactoryGirl.create :user
    with_config(admins: [admin.login]) do
      login admin
      api_get :show, :id => admin.id, :format => :json
      assert_response :success
      assert_json_response admin.to_hash.merge(:is_admin => true)
    end
  end

  test "normal users cannot show user" do
    user = find_record :user
    login
    api_get :show, :id => 0, :login => user.login, :format => :json
    assert_access_denied
  end

  test "api monitor auth can create and destroy test users" do
    # should work even with registration off and/or invites required
    with_config(allow_registration: false, invite_required: true) do
      monitor_auth do
        user_attribs = record_attributes_for :test_user
        api_post :create, :user => user_attribs, :format => :json
        assert_response :success
        api_delete :destroy, :id => assigns(:user).id, :format => :json
        assert_response :success
      end
    end
  end

  test "api monitor auth cannot create normal users" do
    monitor_auth do
      user_attribs = record_attributes_for :user
      api_post :create, :user => user_attribs, :format => :json
      assert_response :forbidden
    end
  end

  test "api monitor auth cannot api_delete normal users" do
    api_post :create, :user => record_attributes_for(:user), :format => :json
    assert_response :success
    normal_user_id = assigns(:user).id
    monitor_auth do
      api_delete :destroy, :id => normal_user_id, :format => :json
      assert_response :forbidden
    end
  end

end
