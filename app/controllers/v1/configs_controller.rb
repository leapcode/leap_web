class V1::ConfigsController < ApiController
  include ControllerExtension::JsonFile

  before_filter :require_login, :unless => :anonymous_access_allowed?
  before_filter :sanitize_id, only: :show

  def index
    render json: {services: service_paths}
  end

  def show
    send_file lookup_file
  end

  protected

  SERVICE_IDS = {
    soledad: "soledad-service",
    eip: "eip-service",
    smtp: "smtp-service"
  }

  def service_paths
    Hash[SERVICE_IDS.map{|k,v| [k,"/1/configs/#{v}.json"] } ]
  end

  def sanitize_id
    @id = params[:id].downcase
    access_denied unless SERVICE_IDS.values.include? @id
  end

  def lookup_file
    path = APP_CONFIG[:config_file_paths][@id]
    not_found if path.blank?
    Rails.root.join path
  end
end
