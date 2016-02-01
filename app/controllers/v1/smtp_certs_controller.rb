class V1::SmtpCertsController < ApiController

  before_filter :require_login
  before_filter :require_email_account
  before_filter :fetch_identity
  before_filter :require_enabled

  # POST /1/smtp_cert
  def create
    @cert = ClientCertificate.new common_name: current_user.email_address
    @identity.register_cert(@cert)
    @identity.save
    render text: @cert.to_s, content_type: 'text/plain'
  end

  protected

  #
  # Filters
  #

  def require_email_account
    access_denied unless service_level.provides? 'email'
  end

  def require_enabled
    access_denied unless current_user.enabled?
  end

  def fetch_identity
    @identity = current_user.identity
  end

  #
  # Helper methods
  #

  def service_level
    current_user.effective_service_level
  end

end
