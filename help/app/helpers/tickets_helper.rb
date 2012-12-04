module TicketsHelper

  def status
    params[:open_status] || 'open'
  end

  def admin
    # do we not want this set for non-admins? the param will be viewable in the url
    params[:admin_status] || 'all'
  end

  def order
    params[:sort_order] || 'updated_at_desc'
  end

  def link_to_status(new_status)
    label = new_status + ' issues'
    link_to label, :open_status => new_status, :admin_status => admin, :sort_order => order
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

    link_to :sort_order => order_field + '_at_' + direction, :open_status => status, :admin_status => admin do
      arrow + order_field + ' at'
    end
  end

end
