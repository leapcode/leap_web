module TicketsHelper

  def status
    params[:open_status] || 'open'
  end

  def admin
    params[:admin_status] || 'all'
  end

  def link_to_status(new_status)
    label = new_status + ' issues'
    link_to label, :open_status => new_status, :admin_status => admin
  end
end
