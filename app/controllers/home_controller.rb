
class HomeController < ApplicationController
  def index
    debugger if params[:debug]
  end
end
