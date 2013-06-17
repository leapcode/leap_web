module TicketsHelper

  def status
    params[:open_status]
  end

  def admin
    # do we not want this set for non-admins? the param will be viewable in the url
    params[:admin_status] || 'all'
  end

  def order
    params[:sort_order] || 'updated_at_desc'
  end

  def link_to_status(new_status)
    if new_status == "open"
      label = t(:open_tickets)
    elsif new_status == "closed"
      label = t(:closed_tickets)
    elsif new_status == "all"
      label = t(:all_tickets)
    end
    link_to label, tickets_path(:open_status => new_status, :admin_status => admin, :sort_order => order)
  end

  def link_to_order(order_field)
    if order.start_with?(order_field)
      # link for currently-filtered field. Link to other direction of this field.
      if order.end_with? 'asc'
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

    link_to :sort_order => order_field + '_at_' + direction, :open_status => status, :admin_status => admin do
      arrow + label
    end
  end

end
