class SrpTest < RackTest

  teardown do
    if @user
      cleanup_user
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

  protected

  attr_reader :server_auth

  def register_user(login = "integration_test_user", password = 'srp, verify me!')
    cleanup_user(login)
    post 'http://api.lvh.me:3000/1/users.json',
      user: user_params(login: login, password: password),
      format: :json
    @user = User.find_by_login(login)
    @login = login
    @password = password
  end

  def update_user(params)
    put "http://api.lvh.me:3000/1/users/" + @user.id + '.json',
      :user => user_params(params),
      :format => :json
  end

  def authenticate(params = nil)
    @server_auth = srp(params).authenticate(self)
  end

  def logout
    delete "http://api.lvh.me:3000/1/logout.json",
      format: :json
  end

  def cleanup_user(login = nil)
    login ||= @user.login
    Identity.by_address.key(login + '@' + APP_CONFIG[:domain]).each do |identity|
      identity.destroy
    end
    if user = User.find_by_login(login)
      user.destroy
    end
  end

  def user_params(params)
    # if there is no srp magic needed just return the params
    return params unless params.keys.include?(:password)
    params.reverse_merge! login: @login, salt: @salt
    @srp = SRP::Client.new params[:login], password: params.delete(:password)
    @salt = srp.salt.to_s(16)
    params.merge :password_verifier => srp.verifier.to_s(16),
      :password_salt => @salt
  end

  def srp(params = nil)
    if params.nil?
      @srp
    else
      params.reverse_merge! password: @password
      SRP::Client.new(params.delete(:login) || @login, params)
    end
  end
end
