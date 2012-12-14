class CertsController < ApplicationController

  before_filter :authorize

  # GET /cert
  def show
    @cert = LeapCA::Cert.pick_from_pool
    render :text => @cert.key + @cert.cert, :content_type => 'text/plain'
  rescue RECORD_NOT_FOUND
    flash[:error] = t(:cert_pool_empty)
    redirect_to root_path
  end

end
