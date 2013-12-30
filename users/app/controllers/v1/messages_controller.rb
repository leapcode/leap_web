module V1
  class MessagesController < ApplicationController

    # TODO need to add authentication
    respond_to :json

    # for now, will not pass unseen, so unseen will always be true
    def user_messages(unseen = true)
      user = User.find(params[:user_id])
      render json: (user ? user.messages : [] )
    end

    # routes ensure this is only for PUT
    def mark_read
=begin
      user_message = UserMessage.find_by_user_id_and_message_id([params[:user_id], params[:message_id]])
      user_message.seen = true if user_message

      # TODO what to return?
      if user_message and user_message.save
        render json: true
      else
        render json: false
      end
    end
=end
      if (user = User.find(params[:user_id])) && Message.find(params[:message_id])
        user.message_ids_seen << params[:message_id] if !user.message_ids_seen.include?(params[:message_id]) #is it quicker to instead run uniq after adding?
        user.message_ids_to_see.delete(params[:message_id])
        user.save
        render json: true
        return
      else
        render json: false
      end

    end
  end
end
