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
        message.user_ids_to_show.delete(current_user.id)
        # is it necessary to keep track of what users have already seen it?:
        message.user_ids_have_shown << current_user.id if !message.user_ids_have_shown.include?(current_user.id) #TODO: is it quicker to instead call uniq! after adding?
        message.save
        render json: true
      else
        render json: false
      end
    end

  end
end
