module UsersHelper

  def user_form_with(partial, legend, locals)
    user_form do |f|
      locals.reverse_merge! :legend => legend, :f => f
      render :partial => partial,
        :layout => 'legend_and_submit',
        :locals => locals
    end
  end

  def user_form
    html_class = 'form-horizontal user form '
    html_class += (@user.new_record? ? 'new' : 'edit')
    simple_form_for @user,
      :validate => true,
      :format => :json,
      :html => {:class => html_class} do |f|
      yield f
    end
  end
end
