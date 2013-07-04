class EmailSettingsController < UsersBaseController

  before_filter :authorize
  before_filter :fetch_user

  def edit
    @email_alias = LocalEmail.new
  end

  def update
    @user.attributes = cleanup_params(params[:user])
    if @user.changed?
      if @user.save
        flash[:notice] = t(:changes_saved)
        redirect
      else
        if @user.email_aliases.last && !@user.email_aliases.last.valid?
          # display bad alias in text field:
          @email_alias = @user.email_aliases.pop
        end
        render 'email_settings/edit'
      end
    else
      redirect
    end
  end

  private

  def redirect
    redirect_to edit_user_email_settings_url(@user)
  end

  def cleanup_params(user)
    if !user['email_forward'].nil? && user['email_forward'].empty?
      user.delete('email_forward') # don't allow "" as an email forward
    end
    user
  end

end
