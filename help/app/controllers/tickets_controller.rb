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
    ticket_access_denied?
    # @ticket.comments.build
    # build ticket comments?
  end
  
  def update
    
    @ticket = Ticket.find(params[:id])
    if !ticket_access_denied?

      #below is excessively complicated. issue is that we don't need a new comment if we have changed anything else (currently, is_open is the only other thing to change.) However, if we don't change anything else, then we want to try to add a new comment (and possibly fail.) Likely this should all be redone.
      @ticket.is_open = params[:ticket][:is_open]
      if !params[:ticket][:comments_attributes].values.first[:body].blank? or !@ticket.changed?
        @ticket.attributes = params[:ticket]
      end
      # what if there is an update and no new comment? Confirm that there is a new comment to update posted_by. will @tickets.comments_changed? work?
      @ticket.comments.last.posted_by = (current_user ? current_user.id : nil) if @ticket.comments_changed? #protecting posted_by isn't working, so this should protect it.
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
  end

  def index
    # @tickets = Ticket.by_title #not actually what we will want
    #we'll want only tickets that this user can access
    # @tickets = Ticket.by_is_open.key(params[:status])

    #below is obviously too messy and not what we want, but wanted to get basic functionality there
    if admin?
      if params[:status] == 'open'
        @tickets = Ticket.by_is_open.key(true)
      elsif params[:status] == 'closed'
        @tickets = Ticket.by_is_open.key(false)
      else
        @tickets = Ticket.all
      end
    elsif logged_in?
      if params[:status] == 'open'
        @tickets = Ticket.by_is_open_and_created_by.key([true, current_user.id]).all
      elsif params[:status] == 'closed'
        @tickets = Ticket.by_is_open_and_created_by.key([false, current_user.id]).all
      else
        @tickets = Ticket.by_created_by.key(current_user.id).all
      end
    else
      access_denied
    end      

    respond_with(@tickets) 
  end

  private
  
  def ticket_access_denied?
    # TODO---we will allow unauthenticated users to view tickets with a code
    if !admin? and current_user.id != @ticket.created_by
      @ticket = nil
      access_denied
    end
   
  end

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
