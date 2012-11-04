require 'test_helper'

class SessionsControllerTest < ActionController::TestCase

  setup do
    @user = stub :login => "me", :id => 123
    @client_hex = 'a123'
  end

  test "should get login screen" do
    request.env['warden'].expects(:winning_strategy)
    get :new
    assert_response :success
    assert_equal "text/html", response.content_type
    assert_template "sessions/new"
  end

  test "renders json" do
    request.env['warden'].expects(:winning_strategy)
    get :new, :format => :json
    assert_response :success
    assert_json_response :errors => nil
  end

  test "renders warden errors" do
    strategy = stub :message => "Warden auth did not work"
    request.env['warden'].expects(:winning_strategy).returns(strategy)
    get :new, :format => :json
    assert_response :success
    assert_json_response :errors => strategy.message
  end

  test "should perform handshake" do
    assert_raises ActionView::MissingTemplate do
      request.env['warden'].expects(:authenticate!)
      post :create, :login => @user.login, 'A' => @client_hex
      assert params['A']
      assert params['login']
    end
  end

  test "should authorize" do
    assert_raises ActionView::MissingTemplate do
      request.env['warden'].expects(:authenticate!)
      session[:handshake] = stub
      post :update, :id => @user.login, :client_auth => @client_hex
      assert params['client_auth']
      assert session[:handshake]
    end
  end

  test "logout should reset warden user" do
    expect_warden_logout
    delete :destroy
    assert_response :redirect
    assert_redirected_to root_url
  end

  def expect_warden_logout
    raw = mock('raw session') do
      expects(:inspect)
    end
    request.env['warden'].expects(:raw_session).returns(raw)
    request.env['warden'].expects(:logout)
  end


end
