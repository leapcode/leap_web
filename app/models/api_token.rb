#
# Works like a regular authentication Token, but is configured in the conf file for
# use by admins or testing.
#
# This is not actually a model, but it used in the place of the normal Token model
# when appropriate
#

require 'digest/sha2'

class ApiToken

  #
  # Searches static config to see if there is a matching api token string.
  # Return an ApiToken if successful, or nil otherwise.
  #
  def self.find_by_token(token, ip_address=nil)
    if APP_CONFIG["api_tokens"].nil? || APP_CONFIG["api_tokens"].empty?
      # no api auth tokens are configured
      return nil
    elsif ip_address && !ip_allowed?(ip_address)
      return nil
    elsif !token.is_a?(String) || token.size < 24
      # don't allow obviously invalid token strings
      return nil
    else
      token_digest = Digest::SHA512.hexdigest(token)
      username = self.static_auth_tokens[token_digest]
      if username
        if username == "monitor"
          return ApiMonitorToken.new
        elsif username == "admin"
          # not yet supported
          return nil
        end
      else
        return nil
      end
    end
  end

  private

  #
  # A static hash to represent the configured api auth tokens, in the form:
  #
  # {
  #    "<sha521 of token>" => "<username>"
  # }
  #
  # SHA512 is used here in order to prevent an attacker from discovering
  # the value for an auth token by measuring the string comparison time.
  #
  def self.static_auth_tokens
    @static_auth_tokens ||= APP_CONFIG["api_tokens"].inject({}) {|hsh, entry|
      if ["monitor", "admin"].include?(entry[0])
        hsh[Digest::SHA512.hexdigest(entry[1])] = entry[0]
      end
      hsh
    }.freeze
  end

  def self.ip_allowed?(ip)
    ip == "0.0.0.0" ||
    ip == "127.0.0.1" || (
      APP_CONFIG["api_tokens"] &&
      APP_CONFIG["api_tokens"]["allowed_ips"].is_a?(Array) &&
      APP_CONFIG["api_tokens"]["allowed_ips"].include?(ip)
    )
  end

end

class ApiAdminToken < ApiToken
  # not yet supported
  #def authenticate
  #  AdminUser.new
  #end
end

#
# These tokens used by the platform to run regular monitor tests
# of a production infrastructure.
#
class ApiMonitorToken < ApiToken
  def authenticate
    ApiMonitorUser.new
  end
end
