class V1::CertsController < ApplicationController

  before_filter :require_eip_access

  # GET /cert
  def show
    @cert = ClientCertificate.new(:prefix => service_level.cert_prefix)
    render text: @cert.to_s, content_type: 'text/plain'
  end

  protected

  def require_eip_access
    access_denied unless service_level.provides?(:eip)
  end

  def service_level
    current_user.effective_service_level
  end
end
