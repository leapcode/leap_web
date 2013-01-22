class WebfingerController < ApplicationController

  respond_to :xml, :json
  layout false

  def host_meta
    @host_meta = Webfinger::HostMetaPresenter.new(request)
    respond_with @host_meta
  end

  def search
    username = params[:q].split('@')[0].to_s.downcase
    user = User.find_by_login(username) || not_found
    @subject = Webfinger::UserPresenter.new(user, request)
    respond_with @subject
  end

end
