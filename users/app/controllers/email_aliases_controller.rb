class EmailAliasesController < ApplicationController

  before_filter :fetch_user

  respond_to :html

  def destroy
    @alias = @user.email_aliases.delete(params[:id])
    @user.save
    flash[:notice] = t(:email_alias_destroyed_successfully, :alias => @alias)
    redirect_to edit_user_path(@user, :anchor => :email)
  end

  protected

  def fetch_user
    @user = User.find_by_param(params[:user_id])
    access_denied unless admin? or (@user == current_user)
  end
end
