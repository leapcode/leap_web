Rails.configuration.middleware.use RailsWarden::Manager do |config|
  config.default_strategies :secure_remote_password
  config.failure_app = SessionsController
  config.default_scope = :user
  config.scope_defaults :user, :action => :new
end

# Setup Session Serialization
class Warden::SessionSerializer
  def serialize(record)
    [record.class.name, record.id]
  end

  def deserialize(keys)
    klass, id = keys
    klass.find(id)
  end
end

Warden::Strategies.add(:secure_remote_password) do

  def valid?
    handshake? || authentication?
  end

  def authenticate!
    if authentication?
      validate!
    else  # handshake
      initialize!
    end
  end

  protected

  def handshake?
    params['A'] && params['login']
  end

  def authentication?
    params['client_auth'] && session[:handshake]
  end

  def validate!
    srp_session = session.delete(:handshake)
    user = srp_session.authenticate(params['client_auth'].hex)
    user.nil? ? fail!("Could not log in") : success!(user)
  end

  def initialize!
    user = User.find_by_param(id)
    session[:handshake] = user.initialize_auth(params['A'].hex)
    custom! json_response(session[:handshake])
  rescue RECORD_NOT_FOUND
    fail! "User not found!"
  end

  def json_response(object)
    [ 200,
      {"Content-Type" => "application/json; charset=utf-8"},
      [object.to_json]
    ]
  end

  def id
    params["id"] || params["login"]
  end
end

