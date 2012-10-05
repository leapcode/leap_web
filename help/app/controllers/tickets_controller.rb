class TicketsController < ApplicationController

  def new
    @ticket = Ticket.new
  end

  def create
    # @ticket = Ticket.new :posted_by => current_user
    @ticket = Ticket.new :created_by => User.current_test.id
    @ticket.attributes = params[:ticket]

    add_comment
    redirect_to @ticket
  end

  def show
    @ticket = Ticket.find(params[:id])
  end
  
  def update
    @ticket = Ticket.find(params[:id])
    add_comment
    redirect_to @ticket
  end

  def index
    @tickets = Ticket.by_title #not actually what we will want
  end

  private
  
  def add_comment
    comment = TicketComment.new(params[:comment])
    #comment.posted_by = current_user #could be nil
    comment.posted_by = User.current_test.id #could be nil
    comment.posted_at = Time.now # TODO: it seems strange to have this here, and not in model. 
    @ticket.comments << comment
    @ticket.save
  end

end
