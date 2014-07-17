#
# This controller is responsible for returning some static config files, such as /provider.json
#
class StaticConfigController < ActionController::Base
  include ControllerExtension::JsonFile

  before_filter :set_minimum_client_version
  before_filter :set_filename
  before_filter :fetch_file

  PROVIDER_JSON = Rails.root.join('config', 'provider', 'provider.json')

  def provider
    send_file
  end

  protected

  # ensure that the header X-Minimum-Client-Version is sent
  # regardless if a 200 or 304 (not modified) or 404 response is sent.
  def set_minimum_client_version
    response.headers["X-Minimum-Client-Version"] =
      APP_CONFIG[:minimum_client_version].to_s
  end

  def set_filename
    @filename = PROVIDER_JSON
  end
end
