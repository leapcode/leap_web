require 'test_helper'

# This is a simple controller unit test.
# We're stubbing out both warden and srp.
# There's an integration test testing the full rack stack and srp
class V1::SessionsControllerTest < ActionController::TestCase

  setup do
    @request.env['HTTP_HOST'] = 'api.lvh.me'
    @user = stub_record :user, {}, true
    @client_hex = 'a123'
  end

  test "renders json" do
    get :new, :format => :json
    assert_response :success
    assert_json_error nil
  end

  test "renders warden errors" do
    request.env['warden.options'] = {attempted_path: 'path/to/controller'}
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

  test "should authenticate" do
    request.env['warden'].expects(:authenticate!)
    @controller.stubs(:current_user).returns(@user)
    handshake = stub(:to_hash => {h: "ash"})
    session[:handshake] = handshake

    post :update, :id => @user.login, :client_auth => @client_hex

    assert_nil session[:handshake]
    assert_response :success
    assert json_response.keys.include?("id")
    assert json_response.keys.include?("token")
    assert token = Token.find_by_token(json_response['token'])
    assert_equal @user.id, token.user_id
  end

  test "destroy should logout" do
    login
    expect_logout
    delete :destroy
    assert_response 204
  end

end
