class TicketSelection

  def initialize(options = {})
    @options = options
    @options[:open_status] ||= 'open'
    @options[:sort_order] ||= 'updated_at_desc'

  end

  def tickets
    #TODO: can this be more succinct?
    if order
      Ticket.send(finder_method).startkey(startkey).endkey(endkey).send(order)
    else
      Ticket.send(finder_method).startkey(startkey).endkey(endkey)
    end
  end

  protected


  def finder_method
    method = 'by_'
    method += 'includes_post_by_and_' if only_mine?
    method += 'is_open_and_' if @options[:open_status] != 'all'
    method += @options[:sort_order].sub(/_(de|a)sc$/, '')
  end

  def startkey
    startkeys = []
    startkeys << @options[:user_id] if only_mine?
    startkeys << (@options[:open_status] == 'open') if @options[:open_status] != 'all'
    startkeys << 0
    startkeys = startkeys.join if startkeys.length == 1 #want string not array if just one thing in array
    startkeys
  end

  def endkey
    endtime = Time.now + 2.days #TODO. this obviously isn't ideal
    if self.startkey.is_a?(Array)
      endkeys = self.startkey
      endkeys.pop
      endkeys << endtime
    else
      endtime
    end
  end

  def order
    'descending' if @options[:sort_order].end_with? 'desc'
  end


  def only_mine?
    !@options[:is_admin] or (@options[:admin_status] == 'mine')
  end

end
