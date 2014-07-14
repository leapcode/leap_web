class V1::ConfigsController < ApiController

  before_filter :require_login

  def index
    render json: CONFIGS
  end

  def show
  end

  CONFIGS = {
    services: {
      soledad: "/1/configs/soledad-service.json",
      eip: "/1/configs/eip-service.json",
      smtp: "/1/configs/smtp-service.json"
    }
  }

end
