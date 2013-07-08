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
    if new_status == "open"
      label = t(:open_tickets)
    elsif new_status == "closed"
      label = t(:closed_tickets)
    elsif new_status == "all"
      label = t(:all_tickets)
    end
    link_to label, auto_tickets_path(:open_status => new_status, :sort_order => search_order)
  end

  def link_to_order(order_field)
    if search_order.start_with?(order_field)
      # link for currently-filtered field. Link to other direction of this field.
      if search_order.end_with? 'asc'
        direction = 'desc'
        icon_direction = 'up'
      else
        direction = 'asc'
        icon_direction = 'down'
      end
      arrow = content_tag(:i, '', class: 'icon-arrow-'+ icon_direction)
    else
      # for not-currently-filtered field, don't display an arrow, and link to descending direction
      arrow = ''
      direction = 'desc'
    end

    if order_field == 'updated'
      label = t(:updated)
    elsif order_field == 'created'
      label = t(:created)
    end

    link_to auto_tickets_path(:sort_order => order_field + '_at_' + direction, :open_status => search_status) do
      arrow + label
    end
  end

end
