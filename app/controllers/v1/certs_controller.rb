class V1::CertsController < ApiController

  before_filter :require_login, :unless => :anonymous_access_allowed?
  before_filter :require_enabled

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

  def require_enabled
    if !current_user.is_anonymous? && !current_user.enabled?
      access_denied
    end
  end

  def service_level
    current_user.effective_service_level
  end
end
