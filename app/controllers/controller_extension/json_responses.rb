module ControllerExtension::JsonResponses
  extend ActiveSupport::Concern

  private

  def success(key)
    json_message :success, key
  end

  def error(key)
    json_message :error, key
  end

  def json_message(type, key)
    long_key = "#{controller_string}.#{action_string}.#{key}"
    { type => key.to_s,
      :message => I18n.t(long_key, cascade: true) }
  end

  def controller_string
    self.class.name.underscore.
      sub(/_controller$/, '').
      sub(/^v\d\//, '')
  end

  def action_string
    params[:action]
  end
end
