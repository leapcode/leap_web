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

end
