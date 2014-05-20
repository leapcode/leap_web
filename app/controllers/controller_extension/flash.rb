module ControllerExtension::Flash
  extend ActiveSupport::Concern

  protected

  def flash_for(resource, options = {})
    return unless resource.changed?
    add_flash_message_for resource
    add_flash_errors_for resource  if options[:with_errors]
  end

  def add_flash_message_for(resource)
    message = flash_message_for(resource)
    type = flash_type_for(resource)
    if message.present?
      flash[type] = message
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
    namespace << flash_type_for(resource)
    namespace.join(".")
  end

  def flash_type_for(resource)
    resource.valid? ? :success : :error
  end

  def add_flash_errors_for(resource)
    return if resource.valid?
    flash[:error] += "<br/>"
    flash[:error] += resource.errors.full_messages.join(". <br/>")
  end
end
