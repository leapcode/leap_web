class EmailAliasesController < UsersBaseController
  before_filter :fetch_user

  def destroy
    @alias = @user.email_aliases.delete(params[:id])
    if @user.save
      flash[:notice] = t(:email_alias_destroyed_successfully, :alias => bold(@alias))
    end
    redirect_to edit_user_email_settings_path(@user)
  end

end
