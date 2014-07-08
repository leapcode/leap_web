#
# This controller is responsible for returning some static config files, such as /provider.json
#
class StaticConfigController < ActionController::Base

  PROVIDER_JSON = File.join(Rails.root, 'config', 'provider', 'provider.json')

  #
  # return the provider.json, ensuring that the header X-Minimum-Client-Version is sent
  # regardless if a 200 or 304 (not modified) response is sent.
  #
  def provider
    response.headers["X-Minimum-Client-Version"] = APP_CONFIG[:minimum_client_version].to_s
    if File.exists?(PROVIDER_JSON)
      if stale?(:last_modified => File.mtime(PROVIDER_JSON))
        response.content_type = 'application/json'
        render :text => File.read(PROVIDER_JSON)
      end
    else
      render json: {error: 'not found'}, status: 404
    end
  end

end
