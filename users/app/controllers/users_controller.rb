class UsersController < ApplicationController

  skip_before_filter :verify_authenticity_token, :only => [:create]

  before_filter :fetch_user, :only => [:edit, :update]
  before_filter :authorize_admin, :only => [:index]

  respond_to :json, :html

  def index
    @users = User.all
  end

  def new
    @user = User.new
  end

  def create
    @user = User.create(params[:user])
    respond_with @user
  end

  def edit
  end

  def update
    @user.update_attributes(params[:user])
    respond_with @user
  end

  protected

  def fetch_user
    @user = User.find_by_param(params[:id])
    access_denied unless @user == current_user
  end
end
