class V1::CertsController < ApplicationController

  before_filter :require_login, :unless => :anonymous_certs_allowed?

  # GET /cert
  # deprecated - we actually create a new cert and that can
  # be reflected in the action. GET /cert will eventually go
  # away and be replaced by POST /cert
  def show
    create
  end

  # POST /cert
  def create
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
