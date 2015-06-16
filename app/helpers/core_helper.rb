#
# Misc. helpers needed throughout.
#
module CoreHelper

  #
  # insert common buttons (download, login, etc)
  #
  def home_page_buttons
    render 'common/home_page_buttons'
  end

  #
  # returns true if the configured service levels contain a level with a price attached
  #
  def paid_service_level?
    APP_CONFIG[:service_levels].present? && APP_CONFIG[:service_levels].detect{|k,v| v['rate'].present?}
  end

  #
  # a bunch of links to the different languages that are available.
  #
  def locales_links
    CommonLanguages.available.collect { |lang|
      link_to(lang.name,
        {:action => params[:action], :controller => params[:controller], :locale => lang.code},
        {:class => (lang.code == I18n.locale ? 'locale active' : 'locale')}
      )
    }.join(" ").html_safe
  end

end
