class TicketsController < ApplicationController

  respond_to :html #, :json
  #has_scope :open, :type => boolean

  def new
    @ticket = Ticket.new
    @ticket.comments.build
  end

  def create
    @ticket = Ticket.new(params[:ticket])
    if current_user
      @ticket.created_by = current_user.id
      @ticket.email = current_user.email if current_user.email
      @ticket.comments.last.posted_by = current_user.id
    else 
      @ticket.comments.last.posted_by = nil #hacky, but protecting this attribute doesn't work right, so this should make sure it isn't set.
    end

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
    
    # what if there is an update and no new comment? Confirm that there is a new comment to update posted_by. will @tickets.comments_changed? work?
    @ticket.comments.last.posted_by = (current_user ? current_user.id : nil) #protecting posted_by isn't working, so this should protect it.

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
    #we'll want only tickets that this user can access
    # @tickets = Ticket.by_is_open.key(params[:status])
    if params[:status] == 'open'
      @tickets = Ticket.by_is_open.key(true)
    elsif params[:status] == 'closed'
      @tickets = Ticket.by_is_open.key(false)
    else
      @tickets = Ticket.all
    end
    respond_with(@tickets) 
  end

  private
  
  # not using now, as we are using comment_attributes= from the Ticket model
=begin
  def add_comment
    comment = TicketComment.new(params[:comment])
    comment.posted_by = User.current.id if User.current #could be nil
    comment.posted_at = Time.now # TODO: it seems strange to have this here, and not in model
    @ticket.comments << comment
  end
=end
end
