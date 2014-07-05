module TicketsHelper
  #
  # FORM HELPERS
  #

  #
  # hidden fields that should be added to ever ticket form.
  # these are use for proper redirection after successful actions.
  #
  def hidden_ticket_fields
    haml_concat hidden_field_tag('open_status', params[:open_status])
    haml_concat hidden_field_tag('sort_order', params[:sort_order])
    haml_concat hidden_field_tag('user_id', params[:user_id])
    ""
  end

  #
  # PARAM HELPERS
  #

  def search_status
    if action?(:index)
      params[:open_status] || 'open'
    else
      nil
    end
  end

  def search_order
    params[:sort_order] || 'updated_at_desc'
  end

  #
  # LINK HELPERS
  #

  def link_to_status(new_status)
    label = ".#{new_status}"
    link_to_navigation label, auto_tickets_path(open_status: new_status, sort_order: search_order)
  end

  def link_to_order(order_field)
    direction = new_direction_for_order(order_field)
    icon = icon_for_direction(direction)
    # for not-currently-filtered field link to descending direction
    direction ||= 'desc'
    label = ".#{order_field}"
    link_to_navigation label, auto_tickets_path(sort_order: order_field + '_at_' + direction, open_status: search_status),
      icon: icon
  end


  def new_direction_for_order(order_field)
    # return if we're not filtering by this field
    return unless search_order.start_with?(order_field)
    # Link to the other direction for the filtered field.
    search_order.end_with?('asc') ? 'desc' : 'asc'
  end

  def icon_for_direction(direction)
    # Don't display an icon if we do not filter this field
    return if direction.blank?
    direction == 'asc' ? 'arrow-down' : 'arrow-up'
  end

end
