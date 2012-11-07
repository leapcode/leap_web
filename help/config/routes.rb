Rails.application.routes.draw do

  resources :tickets, :only => [:new, :create, :index, :show, :update, :destroy]
  #resources :ticket, :only => [:show]
end
