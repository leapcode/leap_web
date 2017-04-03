module UsersHelper

  def user_form_class(*classes)
    (classes + ['user', 'hidden', 'js-show', (@user.new_record? ? 'new' : 'edit')]).compact.join(' ')
  end

  def wrapped(item, options = {})
    options[:as] ||= :div
    content_tag options[:as], :class => dom_class(item), :id => dom_id(item) do
      yield
    end
  end


  def destroy_account_text
    if @user == current_user
      t(:destroy_my_account)
    else
      t(:admin_destroy_account, :username => @user.login)
    end
  end
end
