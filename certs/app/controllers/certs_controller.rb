class CertsController < ApplicationController

  before_filter :authorize

  # GET /cert
  def show
    @cert = Cert.pick_from_pool
    render :text => @cert.zipped, :content_type => 'text/plain'
  end

end
