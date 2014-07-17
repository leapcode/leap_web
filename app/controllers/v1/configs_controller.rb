class V1::ConfigsController < ApiController
  include ControllerExtension::JsonFile

  before_filter :require_login
  before_filter :sanitize_filename, only: :show
  before_filter :fetch_file, only: :show

  def index
    render json: {services: service_paths}
  end

  def show
    send_file
  end

  SERVICES = {
    soledad: "soledad-service.json",
    eip: "eip-service.json",
    smtp: "smtp-service.json"
  }

  protected

  def service_paths
    Hash[SERVICES.map{|k,v| [k,"/1/configs/#{v}"] } ]
  end

  def sanitize_filename
    @filename = params[:id].downcase
    @filename += '.json' unless @filename.ends_with?('.json')
    access_denied unless SERVICES.values.include? name
    @filename = Rails.root.join('public', '1', 'config', @filename)
  end
end
