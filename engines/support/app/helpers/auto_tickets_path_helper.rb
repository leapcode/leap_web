#
# These "auto" forms of the normal ticket path route helpers allow us to do two things automatically:
#
# (1) include the user in the path if appropriate.
# (2) retain the sort params, if appropriate.
#
# Tickets views with a user_id are limited to that user.
# Admins don't need a user_id for any ticket action.
#
# This is available both to the views and the tickets_controller.
#
module AutoTicketsPathHelper

  protected

  def auto_tickets_path(options={})
    options = ticket_view_options.merge options
    if @user.is_a? User
      user_tickets_path(@user, options)
    else
      tickets_path(options)
    end
  end

  def auto_ticket_path(ticket)
    return unless ticket.persisted?
    options = ticket_view_options
    if @user.is_a? User
      user_ticket_path(@user, ticket, options)
    else
      ticket_path(ticket, options)
    end
  end

  def auto_new_ticket_path
    options = ticket_view_options
    if @user.is_a? User
      new_user_ticket_path(@user, options)
    else
      new_ticket_path(options)
    end
  end

  private

  def ticket_view_options
    hash = params.slice(:open_status, :sort_order)
    hash.reject {|k,v| v.blank?}
  end

end
