module UsersHelper

  def user_form_class(*classes)
    (classes + ['user', 'form', (@user.new_record? ? 'new' : 'edit')]).compact.join(' ')
  end

  def wrapped(item, options = {})
    options[:as] ||= :div
    content_tag options[:as], :class => dom_class(item), :id => dom_id(item) do
      yield
    end
  end

end
