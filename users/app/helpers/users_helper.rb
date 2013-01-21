module UsersHelper

  def user_form_with(partial, options = {})
    user_form(options) do |f|
      options[:f] = f
      render :partial => partial,
        :layout => 'legend_and_submit',
        :locals => options
    end
  end

  def user_form(options = {})
    simple_form_for @user,
      :html => user_form_html_options(options),
      :validate => true do |f|
      yield f
    end
  end

  def user_form_html_options(options)
    { :class => user_form_html_classes(options).join(" "),
      :id => dom_id(@user, options[:legend])
    }
  end

  def user_form_html_classes(options)
    classes = %W/form-horizontal user form/
    classes << options[:legend]
    classes << (@user.new_record? ? 'new' : 'edit')
    classes.compact
  end

  def user_field(field)
    value = @user.send(field)
    value = value.to_s(:long) if field.end_with? '_at'
    value || 'not set'
  end

  def wrapped(item, options = {})
    options[:as] ||= :div
    content_tag options[:as], :class => dom_class(item), :id => dom_id(item) do
      yield
    end
  end

end
