class UsersController < ApplicationController

  skip_before_filter :verify_authenticity_token, :only => [:create]

  before_filter :fetch_user, :only => [:edit, :update]

  respond_to :json, :html

  def new
    @user = User.new
  end

  def create
    @user = User.create!(params[:user])
    respond_with(@user, :location => root_url, :notice => "Signed up!")
  rescue VALIDATION_FAILED => e
    @user = e.document
    respond_with(@user, :location => new_user_path)
  end

  def edit
  end

  def update
    @user.update_attributes(params[:user])
    respond_with(@user, :location => edit_user_path(@user))
  end

  protected

  def fetch_user
    @user = User.find_by_param(params[:id])
    access_denied unless @user == current_user
  end
end
