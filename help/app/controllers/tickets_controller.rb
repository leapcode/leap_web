class TicketsController < ApplicationController

  respond_to :html, :json
  #has_scope :open, :type => boolean

  before_filter :set_strings

  before_filter :authorize, :only => [:index]

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
      flash[:notice] = flash[:notice] + ' You can later access this ticket at the url ' + request.protocol + request.host_with_port + ticket_path(@ticket.id) + '. You might want to bookmark this page to find it again. Anybody with this URL will be able to access this ticket, so if you are on a shared computer you might want to remove it from the browser history' #todo
    end
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
    if !@ticket
      redirect_to tickets_path, :alert => "No such ticket"
      return
    end
    ticket_access_denied? #authorize_ticket_access
    # @ticket.comments.build
    # build ticket comments?
  end

  def update
    @ticket = Ticket.find(params[:id])

    if !ticket_access_denied?
      if params[:post] #currently changes to title or is_open status
        if @ticket.update_attributes(params[:post]) #this saves ticket, so @ticket.changed? will be false
          tick_updated = true
        end
        # TODO: do we want to keep the history of title changes? one possibility was adding a comment that said something like 'user changed the title from a to b'

      else
        params[:ticket][:comments_attributes] = nil if params[:ticket][:comments_attributes].values.first[:body].blank? #unset comments hash if no new comment was typed
        @ticket.attributes = params[:ticket] #this will call comments_attributes=
        @ticket.close if params[:commit] == @reply_close_str #this overrides is_open selection
        # what if there is an update and no new comment? Confirm that there is a new comment to update posted_by:
        @ticket.comments.last.posted_by = (current_user ? current_user.id : nil) if @ticket.comments_changed? #protecting posted_by isn't working, so this should protect it.
        tick_updated = true if @ticket.changed? and @ticket.save
      end
      if tick_updated
        flash[:notice] = 'Ticket was successfully updated.'
        if @ticket.is_open
          respond_with @ticket
        else #for closed tickets, redirect to index.
          redirect_to tickets_path
        end
      else
        #redirect_to [:show, @ticket] #
        flash[:alert] = 'Ticket has not been changed'
        redirect_to @ticket
        #respond_with(@ticket) # why does this go to edit?? redirect???
      end
    end

  end

  def index
    @all_tickets = Ticket.for_user(current_user, params, admin?) #for tests, useful to have as separate variable

    #below works if @tickets is a CouchRest::Model::Designs::View, but not if it is an Array
    @tickets = @all_tickets.page(params[:page]).per(10)
    #respond_with(@tickets)
  end

  def destroy
    @ticket = Ticket.find(params[:id])
    @ticket.destroy if admin?
    redirect_to tickets_path
  end

  private

  def ticket_access?
    @ticket and (admin? or !@ticket.created_by or (current_user and current_user.id == @ticket.created_by))
  end

  def ticket_access_denied?
    access_denied unless ticket_access?
  end


  def set_strings
    @post_reply_str = 'Post reply' #t :post_reply
    @reply_close_str = 'Reply and close' #t :reply_and_close
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
