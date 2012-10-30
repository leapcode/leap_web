Rails.configuration.middleware.use Warden::Manager do |manager|
  manager.default_strategies :secure_remote_password
  manager.failure_app = SessionsController
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
    id && ( params['A'] || params['client_auth'] )
  end

  def authenticate!
    if params['client_auth'] && session[:handshake]
      validate!
    else
      initialize!
    end
  end

  protected

  def validate!
    srp_session = session.delete(:handshake)
    user = srp_session.authenticate(params['client_auth'].hex)
    user.nil? ? fail!("Could not log in") : success!(u)
  end

  def initialize!
    user = User.find_by_param(id)
    session[:handshake] = user.initialize_auth(params['A'].hex)
    custom! [200, {}, [session[:handshake].to_json]]
  rescue RECORD_NOT_FOUND
    fail! "User not found"
  end

  def id
    params["id"] || params["login"]
  end
end

