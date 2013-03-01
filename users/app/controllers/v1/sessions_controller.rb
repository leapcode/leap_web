module V1
  class SessionsController < ApplicationController

    skip_before_filter :verify_authenticity_token

    def new
      @session = Session.new
      if authentication_errors
        @errors = authentication_errors
        render :status => 422
      end
    end

    def create
      logout if logged_in?
      authenticate!
    end

    def update
      authenticate!
      render :json => login_response
    end

    def destroy
      logout
      redirect_to root_path
    end

    protected

    def login_response
      handshake = session.delete(:handshake)
      handshake.to_hash.merge(:id => current_user.id)
    end

  end
end
