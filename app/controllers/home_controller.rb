class HomeController < ApplicationController
  layout 'home'

  respond_to :html

  def index
    if logged_in?
      redirect_to current_user
    end
  end
end
