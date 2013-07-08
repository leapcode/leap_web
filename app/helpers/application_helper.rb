module ApplicationHelper

  #
  # determine title for the page
  #
  def html_title
    if content_for?(:title)
      yield(:title)
    elsif @title
      [@title, ' - ', APP_CONFIG[:domain]].join
    else
      APP_CONFIG[:domain]
    end
  end

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

  def big_icon(name, color=nil)
    "<i class=\"big-icon-#{name}\"></i> ".html_safe
  end

  def format_flash(msg)
    html_escape(msg).gsub('[b]', '<b>').gsub('[/b]', '</b>').html_safe
  end

end
