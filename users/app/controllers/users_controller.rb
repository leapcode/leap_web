class UsersController < ApplicationController

  before_filter :authorize, :only => [:show, :edit, :update, :destroy]
  before_filter :fetch_user, :only => [:show, :edit, :update, :destroy]
  before_filter :set_anchor, :only => [:edit, :update]
  before_filter :authorize_admin, :only => [:index]

  respond_to :json, :html

  def index
    if params[:query]
      @users = User.by_login.startkey(params[:query]).endkey(params[:query].succ)
    else
      @users = User.by_created_at.descending
    end
    @users = @users.limit(10)
    respond_with @users.map(&:login).sort
  end

  def new
    @user = User.new
  end

  def create
    @user = User.create(params[:user])
    respond_with @user
  end

  def edit
    @email_alias = LocalEmail.new
  end

  def update
    @user.attributes = params[:user]
    if @user.changed? and @user.save
      flash[:notice] = t(:user_updated_successfully)
    elsif !@user.email_aliases.last.valid?
      @email_alias = @user.email_aliases.pop
    end
    respond_with @user, :location => edit_user_path(@user, :anchor => @anchor)
  end

  def destroy
    @user.destroy
    redirect_to admin? ? users_path : login_path
  end

  protected

  def fetch_user
    # authorize filter has been checked first, so won't get here unless authenticated
    @user = User.find_by_param(params[:id])
    if !@user and admin?
      redirect_to users_path, :alert => t(:no_such_thing, :thing => 'user')
      return
    end
    access_denied unless admin? or (@user == current_user)
  end

  def set_anchor
    @anchor = email_settings? ? :email : :account
  end

  def email_settings?
    params[:user] &&
    params[:user].keys.detect{|key| key.index('email')}
  end
end
