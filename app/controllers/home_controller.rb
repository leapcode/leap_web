class HomeController < ApplicationController
  layout 'home'

  def index
    if logged_in?
      redirect_to current_user
    end
  end
end
