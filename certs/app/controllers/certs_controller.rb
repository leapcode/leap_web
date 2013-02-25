class CertsController < ApplicationController

  # GET /cert
  def show
    @cert = ClientCertificate.new(free: !logged_in?)
    render text: @cert.to_s, content_type: 'text/plain'
  end

end
