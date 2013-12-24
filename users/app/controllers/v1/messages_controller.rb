module V1
  class MessagesController < ApplicationController

    # TODO need to add authentication
    respond_to :json

    # for now, will not pass unseen, so unseen will always be true
    def user_messages(unseen = true)
      user_messages = unseen ? UserMessage.by_user_id_and_seen(:key => [params[:user_id], false]).all : UserMessage.by_user_id(:key => params[:user_id]).all

      messages = []
      user_messages.each do |um|
        messages << Message.find(um.message.id)
      end

      render json: messages
    end


    # routes ensure this is only for PUT
    def mark_read
      user_message = UserMessage.find_by_user_id_and_message_id([params[:user_id], params[:message_id]])
      user_message.seen = true

      # TODO what to return?
      if user_message.save
        render json: true
      else
        render json: false
      end
    end

  end
end
