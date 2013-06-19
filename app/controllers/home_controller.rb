
class HomeController < ApplicationController
  def index
    if logged_in?
      redirect_to user_overview_url(current_user)
    end
    debugger if params[:debug]
  end
end
