class V1::ConfigsController < ApplicationController

  CONFIGS = {
    services: {
      soledad: "/1/configs/soledad-service.json",
      eip: "/1/configs/eip-service.json",
      smtp: "/1/configs/smtp-service.json"
    }
  }

  before_filter :require_login

  def index
    render json: CONFIGS
  end

  def show
  end

end
