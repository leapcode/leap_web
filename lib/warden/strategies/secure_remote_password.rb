module Warden
  module Strategies
    class SecureRemotePassword < Warden::Strategies::Base

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
        if client = validate
          success!(User.find_by_login(client.username))
        else
          Rails.logger.warn "Login attempt failed."
          Rails.logger.debug debug_info
          Rails.logger.debug "Received: #{params['client_auth']}"
          session.delete(:handshake)
          fail!(:base => "invalid_user_pass")
        end
      end

      def validate
        session[:handshake].authenticate(params['client_auth'])
      end

      def initialize!
        if user = User.find_by_login(id)
          client = SRP::Client.new user.username,
            :verifier => user.verifier,
            :salt => user.salt
          session[:handshake] = SRP::Session.new(client, params['A'])
          custom! json_response(session[:handshake])
        else
          fail! :base => 'invalid_user_pass'
        end
      rescue SRP::InvalidEphemeral
        fail!(:base => "invalid_ephemeral")
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

      protected

      def debug_info
        JSON.pretty_generate(session[:handshake].internal_state)
      end

    end
  end
  Warden::Strategies.add :secure_remote_password,
    Warden::Strategies::SecureRemotePassword

end


