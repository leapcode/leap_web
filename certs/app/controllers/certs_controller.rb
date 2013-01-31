class CertsController < ApplicationController

  before_filter :authorize

  # GET /cert
  def show
    @cert = ClientCertificate.new
    render :text => @cert.key + @cert.cert, :content_type => 'text/plain'
  end

end
