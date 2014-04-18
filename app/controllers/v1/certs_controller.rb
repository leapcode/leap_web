class V1::CertsController < ApplicationController

  before_filter :require_login, :unless => :anonymous_certs_allowed?

  # GET /cert
  def show
    @cert = ClientCertificate.new(:prefix => service_level.cert_prefix)
    render text: @cert.to_s, content_type: 'text/plain'
  end

  protected

  def anonymous_certs_allowed?
    APP_CONFIG[:allow_anonymous_certs]
  end

  def service_level
    current_user.effective_service_level
  end
end
