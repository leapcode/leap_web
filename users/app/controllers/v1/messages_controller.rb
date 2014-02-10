module V1
  class MessagesController < ApplicationController

    skip_before_filter :verify_authenticity_token
    before_filter :authorize

    respond_to :json

    def index
      render json: (current_user ? current_user.messages : [] )
    end

    def update
      message = Message.find(params[:id])
      if (message and current_user)
        message.mark_as_read_by(current_user)
        message.save
        render json: true
      else
        render json: false
      end
    end

  end
end
