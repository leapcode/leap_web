module ControllerExtension::Flash
  extend ActiveSupport::Concern

  protected

  def flash_for(resource, options = {})
    return unless resource.changed?
    message = flash_message_for(resource)
    type = flash_type(resource)
    if message.present?
      flash[type] = [message, flash[type]].join(' ')
    end
  end

  def flash_message_for(resource)
    I18n.t flash_i18n_key(resource),
      scope: :flash,
      cascade: true,
      resource: resource.class.model_name.human
  end

  def flash_i18n_key(resource)
    namespace = [action_name]
    namespace += controller_path.split('/')
    namespace << flash_type(resource)
    namespace.join(".")
  end

  def flash_type(resource)
    resource.valid? ? :success : :error
  end

end
