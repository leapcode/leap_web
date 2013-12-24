module V1
  class MessagesController < ApplicationController

    # TODO need to add authentication
    respond_to :json

    def user_messages(unseen = true)
      user_messages = unseen ? UserMessage.by_user_id_and_seen(:key => [params[:user_id], false]).all : UserMessage.by_user_id(:key => params[:user_id]).all

      messages = []
      user_messages.each do |um|
        messages << Message.find(um.message.id)
      end

      render json: messages
    end


    # only for PUT
    def mark_read
      # params[:user_id] params[:message_id]
    end

  end
end
