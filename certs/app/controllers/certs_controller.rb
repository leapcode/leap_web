class CertsController < ApplicationController

  before_filter :require_login, :unless => :anonymous_certs_allowed?

  # GET /cert
  def show
    @cert = ClientCertificate.new(:prefix => certificate_prefix)
    render text: @cert.to_s, content_type: 'text/plain'
  end

  protected

  def anonymous_certs_allowed?
    APP_CONFIG[:allow_anonymous_certs]
  end
  #
  # this is some temporary logic until we store the service level in the user db.
  #
  # better logic might look like this:
  #
  # if logged_in?
  #   service_level = user.service_level
  # elsif allow_anonymous?
  #   service_level = service_levels[:anonymous]
  # else
  #   service_level = nil
  # end
  #
  # if service_level.bandwidth == 'limited' && allow_limited?
  #   prefix = limited
  # elsif allow_unlimited?
  #   prefix = unlimited
  # else
  #   prefix = nil
  # end
  #
  def certificate_prefix
    if logged_in?
      if APP_CONFIG[:allow_unlimited_certs]
        APP_CONFIG[:unlimited_cert_prefix]
      elsif APP_CONFIG[:allow_limited_certs]
        APP_CONFIG[:limited_cert_prefix]
      end
    elsif !APP_CONFIG[:allow_limited_certs]
      APP_CONFIG[:unlimited_cert_prefix]
    else
      APP_CONFIG[:limited_cert_prefix]
    end
  end
end
