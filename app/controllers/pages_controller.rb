#
# Render static pages
#

class PagesController < ApplicationController

  def show
    @show_navigation = false
    render page_name
  end

  private

  def page_name
    request.path.sub(/^\/(#{MATCH_LOCALE}\/)?/, '')
  end

end
