class UsersController < ApplicationController

  skip_before_filter :verify_authenticity_token

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
    @user = current_user
  end

  def update
    @user = current_user
    @user.update!(params[:user])
    respond_with(@user, :location => edit_user_path(@user))
  end
end
