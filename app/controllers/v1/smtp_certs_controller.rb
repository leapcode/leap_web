class V1::SmtpCertsController < ApplicationController

  before_filter :require_login
  before_filter :require_email_account

  # GET /1/smtp_cert
  def show
    @cert = ClientCertificate.new prefix: current_user.email_address
    current_user.identity.cert_fingerprints << @cert.fingerprint
    current_user.identity.save
    render text: @cert.to_s, content_type: 'text/plain'
  end

  protected

  def require_email_account
    access_denied unless service_level.provides? 'email'
  end

  def service_level
    current_user.effective_service_level
  end
end
