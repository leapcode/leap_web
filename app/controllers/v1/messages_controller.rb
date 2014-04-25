module V1
  class MessagesController < ApplicationController

    skip_before_filter :verify_authenticity_token
    before_filter :require_token

    respond_to :json

    def index
      render json: current_user.messages
    end

    def update
      if message = Message.find(params[:id])
        message.mark_as_read_by(current_user)
        message.save
        render json: true
      else
        render json: false
      end
    end

  end
end
