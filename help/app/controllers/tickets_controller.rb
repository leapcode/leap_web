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

    flash[:notice] = 'Ticket was successfully created.' if @ticket.save
    respond_with(@ticket)

  end

=begin
  def edit
    @ticket = Ticket.find(params[:id])
    @ticket.comments.build
    # build ticket comments?
  end
=end

  def show
    @ticket = Ticket.find(params[:id])
    # @ticket.comments.build
    # build ticket comments?
  end
  
  def update
    @ticket = Ticket.find(params[:id])
    @ticket.attributes = params[:ticket]
    #add_comment #or should we use ticket attributes?
    # @ticket.save
    if @ticket.save
      flash[:notice] = 'Ticket was successfully updated.'
      respond_with @ticket
    else
      #redirect_to [:show, @ticket] #
      flash[:alert] = 'Ticket has not been changed'
      redirect_to @ticket
      #respond_with(@ticket) # why does this go to edit?? redirect???
    end
  end

  def index
    # @tickets = Ticket.by_title #not actually what we will want
    respond_with(@tickets = Ticket.all)
  end

  private
  
  # not using now, as we are using comment_attributes= from the Ticket model
  def add_comment
    comment = TicketComment.new(params[:comment])
    comment.posted_by = User.current_test.id if User.current_test #could be nil
    comment.posted_at = Time.now # TODO: it seems strange to have this here, and not in model
    @ticket.comments << comment
  end

end
