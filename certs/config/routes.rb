Rails.application.routes.draw do
  resource :cert, :only => [:show]
end
