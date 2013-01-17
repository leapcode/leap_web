require 'test_helper'

CONFIG_RU = (Rails.root + 'config.ru').to_s
OUTER_APP = Rack::Builder.parse_file(CONFIG_RU).first

class AccountFlowTest < ActiveSupport::TestCase
  include Rack::Test::Methods
  include Warden::Test::Helpers
  include LeapWebCore::AssertResponses

  def app
    OUTER_APP
  end

  def setup
    @login = "integration_test_user"
    User.find_by_login(@login).tap{|u| u.destroy if u}
    @password = "srp, verify me!"
    @srp = SRP::Client.new(@login, @password)
    @user_params = {
      :login => @login,
      :password_verifier => @srp.verifier.to_s(16),
      :password_salt => @srp.salt.to_s(16)
    }
    post 'http://api.lvh.me:3000/1/users.json', :user => @user_params
    @user = User.find_by_param(@login)
  end

  def teardown
    @user.destroy if @user
    Warden.test_reset!
  end

  # this test wraps the api and implements the interface the ruby-srp client.
  def handshake(login, aa)
    post "http://api.lvh.me:3000/1/sessions.json",
      :login => login,
      'A' => aa.to_s(16),
      :format => :json
    response = JSON.parse(last_response.body)
    if response['errors']
      raise RECORD_NOT_FOUND.new(response['errors'])
    else
      return response['B'].hex
    end
  end

  def validate(m)
    put "http://api.lvh.me:3000/1/sessions/" + @login + '.json',
      :client_auth => m.to_s(16),
      :format => :json
    return JSON.parse(last_response.body)
  end

  test "signup response" do
    assert_json_response :login => @login, :ok => true
    assert last_response.successful?
  end

  test "signup and login with srp via api" do
    server_auth = @srp.authenticate(self)
    assert last_response.successful?
    assert_nil server_auth["errors"]
    assert server_auth["M2"]
  end

  test "duplicate login does not break things" do
    server_auth = @srp.authenticate(self)
    server_auth = @srp.authenticate(self)
    assert last_response.successful?
    assert_nil server_auth["errors"]
    assert server_auth["M2"]
  end

  test "signup and wrong password login attempt" do
    srp = SRP::Client.new(@login, "wrong password")
    server_auth = srp.authenticate(self)
    assert_json_error :password => "wrong password"
    assert !last_response.successful?
    assert_nil server_auth["M2"]
  end

  test "signup and wrong username login attempt" do
    srp = SRP::Client.new("wrong_login", @password)
    server_auth = nil
    assert_raises RECORD_NOT_FOUND do
      server_auth = srp.authenticate(self)
    end
    assert_json_error :login => "could not be found"
    assert !last_response.successful?
    assert_nil server_auth
  end

end
