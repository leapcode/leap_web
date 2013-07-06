class TicketSelection

  #
  # supported options:
  #
  # user_id:      id of the user (uuid string)
  # open_status:  open | closed | all
  # sort_order:   updated_at_desc | updated_at_asc | created_at_desc | created_at_asc
  # admin_status: mine | all
  # is_admin:     true | false
  #
  def initialize(options = {})
    @user_id      = options[:user_id].gsub /[^a-z0-9]/, ''
    @open_status  = allow options[:open_status],  'open', 'closed', 'all'
    @sort_order   = allow options[:sort_order],   'updated_at_desc', 'updated_at_asc', 'created_at_desc', 'created_at_asc'
    @admin_status = allow options[:admin_status], 'mine', 'all'
    @is_admin     = allow options[:is_admin],     false, true
  end

  def tickets
    Ticket.send(finder_method).startkey(startkey).endkey(endkey).send(order)
  end

  protected

  def allow(source, *allowed)
    if allowed.include?(source)
      source
    else
      allowed.first
    end
  end

  def finder_method
    method = 'by_'
    method += 'includes_post_by_and_' if only_mine?
    method += 'is_open_and_' if @open_status != 'all'
    method += @sort_order.sub(/_(de|a)sc$/, '')
  end

  def startkey
    startkeys = []
    startkeys << @user_id if only_mine?
    startkeys << (@open_status == 'open') if @open_status != 'all'
    startkeys << 0
    startkeys = startkeys.join if startkeys.length == 1 # want string not array if just one thing in array
    startkeys
  end

  def endkey
    endtime = Time.now + 2.days # TODO. this obviously isn't ideal
    if self.startkey.is_a?(Array)
      endkeys = self.startkey
      endkeys.pop
      endkeys << endtime
    else
      endtime
    end
  end

  def order
    # we have defined the ascending method to return the view itself:
    (@sort_order.end_with? 'desc') ? 'descending' : 'ascending'
  end


  def only_mine?
    !@is_admin || @admin_status == 'mine'
  end

end
