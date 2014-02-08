module V1
  class SessionsController < ApplicationController

    skip_before_filter :verify_authenticity_token
    before_filter :require_token, only: :destroy

    def new
      @session = Session.new
      if authentication_errors
        @errors = authentication_errors
        render :status => 422
      end
    end

    def create
      logout if logged_in?
      if params['A']
        authenticate!
      else
        @user = User.find_by_login(params['login'])
        render :json => {salt: @user.salt}
      end
    end

    def update
      authenticate!
      @token = Token.create(:user_id => current_user.id)
      session[:token] = @token.id
      render :json => login_response
    end

    def destroy
      logout
      head :no_content
    end

    protected

    def login_response
      handshake = session.delete(:handshake) || {}
      handshake.to_hash.merge(:id => current_user.id, :token => @token.id)
    end

  end
end
