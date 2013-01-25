require 'test_helper'

class WebfingerControllerTest < ActionController::TestCase

  test "get host meta xml" do
    get :host_meta, :format => :xml
    assert_response :success
    assert_equal "application/xml", response.content_type
  end

  test "get host meta json" do
    get :host_meta, :format => :json
    assert_response :success
    assert_equal "application/json", response.content_type
  end

  test "get user webfinger xml" do
    @user = stub_record :user, :public_key => 'my public key'
    User.stubs(:find_by_login).with(@user.login).returns(@user)
    get :search, :q => @user.email_address.to_s, :format => :xml
    assert_response :success
    assert_equal "application/xml", response.content_type
  end

  test "get user webfinger json" do
    @user = stub_record :user, :public_key => 'my public key'
    User.stubs(:find_by_login).with(@user.login).returns(@user)
    get :search, :q => @user.email_address.to_s, :format => :json
    assert_response :success
    assert_equal "application/json", response.content_type
  end

end
