class CertsController < ApplicationController

  before_filter :logged_in_or_free_certs

  # GET /cert
  def show
    @cert = ClientCertificate.new(free: !logged_in?)
    render text: @cert.to_s, content_type: 'text/plain'
  end

  protected

  def logged_in_or_free_certs
    authorize unless APP_CONFIG[:free_certs_enabled]
  end
end
