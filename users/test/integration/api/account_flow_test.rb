require 'test_helper'
require_relative 'rack_test'

class AccountFlowTest < RackTest

  setup do
    @login = "integration_test_user"
    User.find_by_login(@login).tap{|u| u.destroy if u}
    @password = "srp, verify me!"
    @srp = SRP::Client.new @login, :password => @password
    @user_params = {
      :login => @login,
      :password_verifier => @srp.verifier.to_s(16),
      :password_salt => @srp.salt.to_s(16)
    }
    post 'http://api.lvh.me:3000/1/users.json', :user => @user_params
    @user = User.find_by_login(@login)
  end

  teardown do
    if @user
      @user.identity.destroy
      @user.destroy
    end
    Warden.test_reset!
  end

  # this test wraps the api and implements the interface the ruby-srp client.
  def handshake(login, aa)
    post "http://api.lvh.me:3000/1/sessions.json",
      :login => login,
      'A' => aa,
      :format => :json
    response = JSON.parse(last_response.body)
    if response['errors']
      raise RECORD_NOT_FOUND.new(response['errors'])
    else
      return response['B']
    end
  end

  def validate(m)
    put "http://api.lvh.me:3000/1/sessions/" + @login + '.json',
      :client_auth => m,
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

  test "signup and wrong password login attempt" do
    srp = SRP::Client.new @login, :password => "wrong password"
    server_auth = srp.authenticate(self)
    assert_json_error "base" => "Not a valid username/password combination"
    assert !last_response.successful?
    assert_nil server_auth["M2"]
  end

  test "signup and wrong username login attempt" do
    srp = SRP::Client.new "wrong_login", :password => @password
    server_auth = nil
    assert_raises RECORD_NOT_FOUND do
      server_auth = srp.authenticate(self)
    end
    assert_json_error "base" => "Not a valid username/password combination"
    assert !last_response.successful?
    assert_nil server_auth
  end

  test "update user" do
    server_auth = @srp.authenticate(self)
    test_public_key = 'asdlfkjslfdkjasd'
    original_login = @user.login
    new_login = 'zaph'
    User.find_by_login(new_login).try(:destroy)
    Identity.by_address.key(new_login + '@' + APP_CONFIG[:domain]).each do |identity|
      identity.destroy
    end
    put "http://api.lvh.me:3000/1/users/" + @user.id + '.json', :user => {:public_key => test_public_key, :login => new_login}, :format => :json
    assert last_response.successful?
    assert_equal test_public_key, Identity.for(@user).keys[:pgp]
    # does not change login if no password_verifier is present
    assert_equal original_login, @user.login
    # eventually probably want to remove most of this into a non-integration functional test
    # should not overwrite public key:
    put "http://api.lvh.me:3000/1/users/" + @user.id + '.json', :user => {:blee => :blah}, :format => :json
    assert_equal test_public_key, Identity.for(@user).keys[:pgp]
    # should overwrite public key:
    put "http://api.lvh.me:3000/1/users/" + @user.id + '.json', :user => {:public_key => nil}, :format => :json
    assert_nil Identity.for(@user).keys[:pgp]
  end

end
