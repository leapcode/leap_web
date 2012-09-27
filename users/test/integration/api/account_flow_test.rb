require 'test_helper'

class AccountFlowTest < ActionDispatch::IntegrationTest

  # this test wraps the api and implements the interface the ruby-srp client.
  def handshake(login, aa)
    post "sessions", :login => login, 'A' => aa.to_s(16)
    assert_response :success
    response = JSON.parse(@response.body)
    if response['errors']
      raise RECORD_NOT_FOUND.new(response['errors'])
    else
      return response['B'].hex
    end
  end

  def validate(m)
    put "sessions/" + @login, :client_auth => m.to_s(16)
    assert_response :success
    return JSON.parse(@response.body)
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
  end

  def teardown
    @user.destroy if @user # make sure we can run this test again
  end

  test "signup and login with srp via api" do
    post '/users.json', :user => @user_params
    @user = User.find_by_param(@login)
    assert_json_response @user_params.slice(:login, :password_salt)
    assert_response :success
    server_auth = @srp.authenticate(self, @login, @password)
    assert_nil server_auth["errors"]
    assert server_auth["M2"]
  end

  test "signup and wrong password login attempt" do
    post '/users.json', :user => @user_params
    @user = User.find_by_param(@login)
    assert_json_response @user_params.slice(:login, :password_salt)
    assert_response :success
    server_auth = @srp.authenticate(self, @login, "wrong password")
    assert_equal ["wrong password"], server_auth["errors"]['password']
    assert_nil server_auth["M2"]
  end

  test "signup and wrong username login attempt" do
    post '/users.json', :user => @user_params
    @user = User.find_by_param(@login)
    assert_json_response @user_params.slice(:login, :password_salt)
    assert_response :success
    assert_raises RECORD_NOT_FOUND do
      server_auth = @srp.authenticate(self, "wronglogin", @password)
    end
  end

end
