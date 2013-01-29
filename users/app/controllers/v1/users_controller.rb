module V1
  class UsersController < ApplicationController

    skip_before_filter :verify_authenticity_token
    before_filter :authorize, :only => [:update]

    respond_to :json

    def create
      @user = User.create(params[:user])
      respond_with @user # return ID instead?
    end

    def update
      @user = User.find_by_param(params[:id])
      @user.update_attributes(params[:user])
      respond_with @user
    end

  end
end
