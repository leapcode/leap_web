module WrappedButton
  def wrapped_button(*args, &block)
    template.content_tag :div, :class => "form-actions" do
      options = args.extract_options!
      options[:class] = ['btn-primary', options[:class]].compact
      args.unshift :loading
      args << options
      if cancel = options.delete(:cancel)
        cancel_link = template.link_to I18n.t('simple_form.buttons.cancel'),
          cancel, class: :btn
        button(*args, &block) + ' ' + cancel_link
      else
        button(*args, &block)
      end
    end
  end
end
SimpleForm::FormBuilder.send :include, WrappedButton

module LoadingButton
  def loading_button(*args, &block)
    options = args.extract_options!
    options[:"data-loading-text"] = I18n.t('simple_form.buttons.loading')
    args << options
    button_button(*args, &block)
  end
end
SimpleForm::FormBuilder.send :include, LoadingButton
