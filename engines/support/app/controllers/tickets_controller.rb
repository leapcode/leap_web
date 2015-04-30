class TicketsController < ApplicationController
  include AutoTicketsPathHelper

  respond_to :html, :json
  #has_scope :open, :type => boolean

  before_filter :require_login, :only => [:index]
  before_filter :fetch_ticket, except: [:new, :create, :index]
  before_filter :require_ticket_access, except: [:new, :create, :index]
  before_filter :fetch_user
  before_filter :set_title

  def new
    @ticket = Ticket.new
    @ticket.created_by = current_user.id
    @ticket.comments.build
  end

  def create
    @ticket = Ticket.new(params[:ticket])

    #protecting posted_by isn't working, so this should protect it:
    @ticket.comments.last.posted_by = current_user.id
    @ticket.comments.last.private = false unless admin?
    @ticket.created_by = current_user.id
    flash_for @ticket
    if @ticket.save && !logged_in?
      flash[:success] += t 'tickets.access_ticket_text',
        full_url: ticket_url(@ticket.id),
        default: ""
    end
    respond_with @ticket, :location => auto_ticket_path(@ticket)
  end

  def show
    @comment = TicketComment.new
    if !@ticket
      redirect_to auto_tickets_path, :alert => t(:no_such_thing, :thing => t(:ticket))
      return
    end
  end

  def close
    @ticket.close
    @ticket.save
    redirect_to redirection_path
  end

  def open
    @ticket.reopen
    @ticket.save
    redirect_to redirection_path
  end

  def update
    @ticket.attributes = cleanup_ticket_params(params[:ticket])

    if params[:button] == 'reply_and_close'
      @ticket.close
    end

    if @ticket.comments_changed?
      @ticket.comments.last.posted_by = current_user.id
      @ticket.comments.last.private = false unless admin?
      send_email_update(@ticket, @ticket.comments.last)
    end

    flash_for @ticket, with_errors: true
    @ticket.save
    respond_with @ticket, location: redirection_path
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
    @title = t("layouts.title.tickets")
  end

  private

  #
  # ticket index, if appropriate.
  # otherwise, just @ticket
  #
  def redirection_path
    if logged_in? && params[:button] == t(:reply_and_close)
      auto_tickets_path
    else
      auto_ticket_path(@ticket)
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

  def fetch_ticket
    @ticket = Ticket.find(params[:id])
    if !@ticket
      if admin?
        redirect_to auto_tickets_path,
          alert: t(:no_such_thing, thing: 'ticket')
      else
        access_denied
      end
    end
  end

  def require_ticket_access
    access_denied unless ticket_access?
  end

  def ticket_access?
    admin? or
      @ticket.created_by.blank? or
      current_user.id == @ticket.created_by
  end

  def fetch_user
    if admin?
      @user = User.find(params[:user_id]) if params[:user_id]
    else
      @user = current_user
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

  def send_email_update(ticket, comment)
    TicketMailer.send_notice(ticket, comment, ticket_url(ticket))
  rescue StandardError => exc
    flash_for(exc)
    raise exc if Rails.env == 'development'
  end

end
