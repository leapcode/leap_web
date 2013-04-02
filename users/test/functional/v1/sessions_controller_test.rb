require 'test_helper'

# This is a simple controller unit test.
# We're stubbing out both warden and srp.
# There's an integration test testing the full rack stack and srp
class V1::SessionsControllerTest < ActionController::TestCase

  setup do
    @request.env['HTTP_HOST'] = 'api.lvh.me'
    @user = stub_record :user
    @client_hex = 'a123'
  end

  test "renders json" do
    request.env['warden'].expects(:winning_strategy)
    get :new, :format => :json
    assert_response :success
    assert_json_error nil
  end

  test "renders warden errors" do
    strategy = stub :message => {:field => :translate_me}
    request.env['warden'].stubs(:winning_strategy).returns(strategy)
    I18n.expects(:t).with(:translate_me).at_least_once.returns("translation stub")
    get :new, :format => :json
    assert_response 422
    assert_json_error :field => "translation stub"
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
    @controller.expects(:current_user).returns(@user)
    handshake = stub(:to_hash => {h: "ash"})
    session[:handshake] = handshake

    post :update, :id => @user.login, :client_auth => @client_hex

    assert_nil session[:handshake]
    assert_response :success
    assert_json_response handshake.to_hash.merge(id: @user.id)
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
