class TicketsController < ApplicationController

  respond_to :html, :json
  #has_scope :open, :type => boolean

  before_filter :set_strings

  before_filter :authorize, :only => [:index]
  before_filter :fetch_ticket, :only => [:show, :update, :destroy] # don't now have an edit method

  def new
    @ticket = Ticket.new
    @ticket.comments.build
  end

  def create
    @ticket = Ticket.new(params[:ticket])
    if logged_in?
      @ticket.created_by = current_user.id
      @ticket.email = current_user.email if current_user.email
      @ticket.comments.last.posted_by = current_user.id
    else
      @ticket.comments.last.posted_by = nil #hacky, but protecting this attribute doesn't work right, so this should make sure it isn't set.
    end
    flash[:notice] = 'Ticket was successfully created.' if @ticket.save
    if !logged_in?
      # cannot set this until ticket has been saved, as @ticket.id will not be set
      flash[:notice] += " " + t(:access_ticket_text, :full_url => request.protocol + request.host_with_port + ticket_path(@ticket.id))
    end
    respond_with(@ticket)

  end

=begin
  def edit
    @ticket.comments.build
    # build ticket comments?
  end
=end

  def show
    @comment = TicketComment.new
    if !@ticket
      redirect_to tickets_path, :alert => "No such ticket"
      return
    end
  end

  def update

    if params[:post] #currently changes to title or is_open status
      @ticket.attributes = params[:post]
      # TODO: do we want to keep the history of title changes? one possibility was adding a comment that said something like 'user changed the title from a to b'

    else
      params[:ticket][:comments_attributes] = nil if params[:ticket][:comments_attributes].values.first[:body].blank? #unset comments hash if no new comment was typed
      @ticket.attributes = params[:ticket] #this will call comments_attributes=
      @ticket.close if params[:commit] == @reply_close_str #this overrides is_open selection
      # what if there is an update and no new comment? Confirm that there is a new comment to update posted_by:
      @ticket.comments.last.posted_by = (current_user ? current_user.id : nil) if @ticket.comments_changed? #protecting posted_by isn't working, so this should protect it.
    end
    if @ticket.changed? and @ticket.save
      flash[:notice] = 'Ticket was successfully updated.'
      if @ticket.is_open || !logged_in?
        respond_with @ticket
      else #for closed tickets with authenticated users, redirect to index.
        redirect_to tickets_path
      end
    else
      #redirect_to [:show, @ticket] #
      flash[:alert] = 'Ticket has not been changed'
      redirect_to @ticket
      #respond_with(@ticket) # why does this go to edit?? redirect???
    end

  end

  def index
    @all_tickets = Ticket.for_user(current_user, params, admin?) #for tests, useful to have as separate variable
    @tickets = @all_tickets.page(params[:page]).per(10)
  end

  def destroy
    # should we allow non-admins to delete their own tickets? i don't think necessary.
    @ticket.destroy if admin?
    redirect_to tickets_path
  end

  private

  def ticket_access?
    @ticket and (admin? or !@ticket.created_by or (current_user and current_user.id == @ticket.created_by))
  end

  def set_strings
    @post_reply_str = 'Post reply' #t :post_reply
    @reply_close_str = 'Reply and close' #t :reply_and_close
  end

  def fetch_ticket
    @ticket = Ticket.find(params[:id])
    if !@ticket and admin?
      redirect_to tickets_path, :alert => t(:no_such_thing, :thing => 'ticket')
      return
    end
    access_denied unless ticket_access?
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
