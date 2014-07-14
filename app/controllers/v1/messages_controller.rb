module V1
  class MessagesController < ApiController

    before_filter :require_login

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
