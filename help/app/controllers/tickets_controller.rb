class TicketsController < ApplicationController
  include AutoTicketsPathHelper

  respond_to :html, :json
  #has_scope :open, :type => boolean

  before_filter :authorize, :only => [:index]
  before_filter :fetch_ticket, :only => [:show, :update, :destroy] # don't now have an edit method
  before_filter :fetch_user
  before_filter :set_title

  def new
    @ticket = Ticket.new
    @ticket.comments.build
  end

  def create
    @ticket = Ticket.new(params[:ticket])

    @ticket.comments.last.posted_by = (logged_in? ? current_user.id : nil) #protecting posted_by isn't working, so this should protect it.
    @ticket.comments.last.private = false unless admin?
    @ticket.created_by = current_user.id if logged_in?
    @ticket.email = current_user.email_address if logged_in? and current_user.email_address

    if @ticket.save
      flash[:notice] = t(:thing_was_successfully_created, :thing => t(:ticket))
    end

    # cannot set this until ticket has been saved, as @ticket.id will not be set
    if !logged_in? and flash[:notice]
      flash[:notice] += " " + t(:access_ticket_text, :full_url => ticket_url(@ticket.id))
    end
    respond_with(@ticket, :location => auto_ticket_path(@ticket))
  end

  def show
    @comment = TicketComment.new
    if !@ticket
      redirect_to auto_tickets_path, :alert => t(:no_such_thing, :thing => t(:ticket))
      return
    end
  end

  def update
    if params[:commit] == 'close'
      @ticket.is_open = false
      @ticket.save
      redirect_to_tickets
    elsif params[:commit] == 'open'
      @ticket.is_open = true
      @ticket.save
      redirect_to auto_ticket_path(@ticket)
    else
      @ticket.attributes = cleanup_ticket_params(params[:ticket])

      if params[:commit] == 'reply_and_close'
        @ticket.close
      end

      if @ticket.comments_changed?
        @ticket.comments.last.posted_by = (current_user ? current_user.id : nil)
        @ticket.comments.last.private = false unless admin?
      end

      if @ticket.changed? and @ticket.save
        flash[:notice] = t(:changes_saved)
        redirect_to_tickets
      else
        flash[:error] = @ticket.errors.full_messages.join(". ") if @ticket.changed?
        redirect_to auto_ticket_path(@ticket)
      end
    end
  end

  def index
    @all_tickets = Ticket.search(search_options(params))
    @tickets = @all_tickets.page(params[:page]).per(APP_CONFIG[:pagination_size])
  end

  def destroy
    # should we allow non-admins to delete their own tickets? i don't think necessary.
    @ticket.destroy if admin?
    redirect_to auto_tickets_path
  end

  protected

  def set_title
    @title = t(:tickets)
  end

  private

  #
  # redirects to ticket index, if appropriate.
  # otherwise, just redirects to @ticket
  #
  def redirect_to_tickets
    if logged_in?
      if params[:commit] == t(:reply_and_close)
        redirect_to auto_tickets_path
      else
        redirect_to auto_ticket_path(@ticket)
      end
    else
      # if we are not logged in, there is no index to view
      redirect_to auto_ticket_path(@ticket)
    end
  end

  #
  # unset comments hash if no new comment was typed
  #
  def cleanup_ticket_params(ticket)
    if ticket && ticket[:comments_attributes]
      if ticket[:comments_attributes].values.first[:body].blank?
        ticket[:comments_attributes] = nil
      end
    end
    return ticket
  end

  def ticket_access?
    @ticket and (admin? or !@ticket.created_by or (current_user and current_user.id == @ticket.created_by))
  end

  def fetch_ticket
    @ticket = Ticket.find(params[:id])
    if !@ticket and admin?
      redirect_to auto_tickets_path, :alert => t(:no_such_thing, :thing => 'ticket')
      return
    end
    access_denied unless ticket_access?
  end

  def fetch_user
    if params[:user_id]
      @user = User.find(params[:user_id])
    end
  end

  #
  # clean up params for ticket search
  #
  def search_options(params)
    params.merge(
      :admin_status => params[:user_id] ? 'mine' : 'all',
      :user_id      => @user ? @user.id : current_user.id,
      :is_admin     => admin?
    )
  end

end
