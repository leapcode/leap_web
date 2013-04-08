require 'test_helper'

# This is a simple controller unit test.
# We're stubbing out both warden and srp.
# There's an integration test testing the full rack stack and srp
class SessionsControllerTest < ActionController::TestCase

  setup do
    @user = stub :login => "me", :id => 123
    @client_hex = 'a123'
  end

  test "should get login screen" do
    get :new
    assert_response :success
    assert_equal "text/html", response.content_type
    assert_template "sessions/new"
  end

  test "renders json" do
    get :new, :format => :json
    assert_response :success
    assert_json_error nil
  end

  test "renders warden errors" do
    request.env['warden.options'] = {attempted_path: '/1/sessions/asdf.json'}
    strategy = stub :message => {:field => :translate_me}
    request.env['warden'].stubs(:winning_strategy).returns(strategy)
    I18n.expects(:t).with(:translate_me).at_least_once.returns("translation stub")
    get :new, :format => :json
    assert_response 422
    assert_json_error :field => "translation stub"
  end

  test "renders failed attempt message" do
    request.env['warden.options'] = {attempted_path: '/1/sessions/asdf.json'}
    request.env['warden'].stubs(:winning_strategy).returns(nil)
    get :new, :format => :json
    assert_response 422
    assert_json_error :login => I18n.t(:all_strategies_failed)
  end

  # Warden takes care of parsing the params and
  # rendering the response. So not much to test here.
  test "should perform handshake" do
    request.env['warden'].expects(:authenticate!)
    # make sure we don't get a template missing error:
    @controller.stubs(:render)
    post :create, :login => @user.login, 'A' => @client_hex
  end

  test "should authorize" do
    request.env['warden'].expects(:authenticate!)
    handshake = stub(:to_json => "JSON")
    session[:handshake] = handshake

    post :update, :id => @user.login, :client_auth => @client_hex

    assert_nil session[:handshake]
    assert_response :success
    assert_json_response handshake
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
