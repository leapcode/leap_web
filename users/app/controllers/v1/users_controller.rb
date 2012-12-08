module V1
  class UsersController < ApplicationController

    skip_before_filter :verify_authenticity_token, :only => [:create]

    respond_to :json

    def create
      @user = User.create(params[:user])
      respond_with @user
    end
  end
end
