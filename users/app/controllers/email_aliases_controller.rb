class EmailAliasesController < ApplicationController

  before_filter :fetch_user

  respond_to :html

  # get a list of email aliases for the given user?
  def index
    @aliases = @user.email_aliases
    respond_with @aliases
  end

  def create
    @alias = @user.add_email_alias(params[:email_alias])
    flash[:notice] = t(:email_alias_created_successfully) unless @alias.errors
    respond_with @alias, :location => edit_user_path(@user, :anchor => :email)
  end

  def update
    @alias = @user.get_email_alias(params[:id])
    @alias.set_email(params[:email_alias])
    flash[:notice] = t(:email_alias_updated_successfully) unless @alias.errors
    respond_with @alias, :location => edit_user_path(@user, :anchor => :email)
  end

  def destroy
    @alias = @user.get_email_alias(params[:id])
    flash[:notice] = t(:email_alias_destroyed_successfully)
    @alias.destroy
    redirect_to edit_user_path(@user, :anchor => :email)
  end

  protected

  def fetch_user
    @user = User.find_by_param(params[:user_id])
    access_denied unless admin? or (@user == current_user)
  end
end
