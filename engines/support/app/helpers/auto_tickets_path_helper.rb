#
# These "auto" forms of the normal ticket path route helpers allow us to do two things automatically:
#
# (1) include the user in the path if appropriate.
# (2) retain the sort params, if appropriate.
#
# Tickets views with a user_id are limited to that user. For admins, they don't need a user_id for any ticket action.
#
# This is available both to the views and the tickets_controller.
#
module AutoTicketsPathHelper

  protected

  def auto_tickets_path(options={})
    return unless options.class == Hash
    options = ticket_view_options.merge options
    if @user
      user_tickets_path(@user, options)
    else
      tickets_path(options)
    end
  end

  def auto_ticket_path(ticket, options={})
    return unless ticket.persisted?
    options = ticket_view_options.merge options
    if @user
      user_ticket_path(@user, ticket, options)
    else
      ticket_path(ticket, options)
    end
  end

  def auto_new_ticket_path(options={})
    return unless options.class == Hash
    options = ticket_view_options.merge options
    if @user
      new_user_ticket_path(@user, options)
    else
      new_ticket_path(options)
    end
  end

  private

  def ticket_view_options
    hsh = {}
    hsh[:open_status] = params[:open_status] if params[:open_status] && !params[:open_status].empty?
    hsh[:sort_order]  = params[:sort_order]  if params[:sort_order]  && !params[:sort_order].empty?
    hsh
  end

end
