class TicketsController < ApplicationController

  respond_to :html #, :json

  def new
    @ticket = Ticket.new
    @ticket.comments.build
  end

  def create
    @ticket = Ticket.new #:created_by => User.current_test.id
    @ticket.attributes = params[:ticket]#.except(:comments)
    @ticket.created_by = User.current_test.id if User.current_test
    #instead of calling add_comment, we are using comment_attributes= from the Ticket model

    if @ticket.save
      respond_with(@ticket)
    else
      respond_with(@ticket, :location => new_ticket_path  )
    end

  end

  def show
    @ticket = Ticket.find(params[:id])
    # build ticket comments?
  end
  
  def update
    @ticket = Ticket.find(params[:id])
    add_comment #or should we use ticket attributes?
    @ticket.save
    redirect_to @ticket #difft behavior on failure?
  end

  def index
    # @tickets = Ticket.by_title #not actually what we will want
    respond_with(@tickets = Ticket.all)
  end

  private
  
  # not using now when creating tickets, we are using comment_attributes= from the Ticket model
  #not yet sure about updating tickets
  def add_comment
    comment = TicketComment.new(params[:comment])
    comment.posted_by = User.current_test.id if User.current_test #could be nil
    comment.posted_at = Time.now # TODO: it seems strange to have this here, and not in model
    @ticket.comments << comment
  end

end
