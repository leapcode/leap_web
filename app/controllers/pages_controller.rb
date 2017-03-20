#
# Render static pages
#


class PagesController < ApplicationController
  respond_to :html

  def show
    @show_navigation = false
    render page_name
  rescue ActionView::MissingTemplate
    raise ActionController::RoutingError.new('Not Found')
  end

  private

  def page_name
    request.path.sub(/^\/(#{CommonLanguages.match_available}\/)?/, '')
  end

end
