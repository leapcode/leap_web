module ApplicationHelper

  #
  # markup for bootstrap icon
  #
  # http://twitter.github.io/bootstrap/base-css.html#icons
  #
  def icon(name, color=nil)
    if color.nil?
      color_class = nil
    elsif color == :black
      color_class = 'icon-black'
    elsif color == :white
      color_class = 'icon-white'
    end
    "<i class=\"icon-#{name} #{color_class}\"></i> ".html_safe
  end

end
