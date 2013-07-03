module V1
  class UsersController < UsersBaseController

    skip_before_filter :verify_authenticity_token
    before_filter :authorize, :only => [:update]
    before_filter :fetch_user, :only => [:update]

    respond_to :json

    def create
      @user = User.create(params[:user])
      respond_with @user # return ID instead?
    end

    def update
      @user = User.find_by_param(params[:id])
      @user.update_attributes params[:user]
      if @user.valid?
        flash[:notice] = t(:user_updated_successfully)
      end
      respond_with @user
    end

  end
end
