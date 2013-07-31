class HomeController < ApplicationController
  layout 'home'

  def index
    if logged_in?
      redirect_to user_overview_url(current_user)
    end
  end
end
