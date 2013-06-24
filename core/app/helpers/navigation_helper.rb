module NavigationHelper

  #
  # used to create a side navigation link.
  #
  # Signature is the same as link_to, except it accepts an :active value in the html_options
  #
  def link_to_navigation(*args)
    if args.last.is_a? Hash
      html_options = args.pop.dup
      active_class = html_options.delete(:active) ? 'active' : nil
      html_options[:class] = [html_options[:class], active_class].join(' ')
      args << html_options
    else
      active_class = nil
    end
    content_tag :li, :class => active_class do
      link_to(*args)
    end
  end

  #
  # returns true if params[:action] matches one of the args.
  #
  def action?(*actions)
    actions.detect do |action|
      if action.is_a? String
        action == action_string
      elsif action.is_a? Symbol
        if action == :none
          action_string == nil
        else
          action == action_symbol
        end
      end
    end
  end

  #
  # returns true if params[:controller] matches one of the args.
  #
  # for example:
  #   controller?(:me, :home)
  #   controller?('groups/')  <-- matches any controller in namespace 'groups'
  #
  def controller?(*controllers)
    controllers.each do |cntr|
      if cntr.is_a? String
        if cntr.ends_with?('/')
          return true if controller_string.starts_with?(cntr.chop)
        end
        return true if cntr == controller_string
      elsif cntr.is_a? Symbol
        return true if cntr == controller_symbol
      end
    end
    return false
  end

  private

  def controller_string
    @controller_string ||= params[:controller].to_s.gsub(/^\//, '')
  end

  def controller_symbol
    @controller_symbol ||= params[:controller].gsub(/^\//,'').gsub('/','_').to_sym
  end

  def action_string
    params[:action]
  end

  def action_symbol
    @action_symbol ||= if params[:action].present?
      params[:action].to_sym
    else
      nil
    end
  end

end
