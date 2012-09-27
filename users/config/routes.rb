Rails.application.routes.draw do

  get "log_in" => "sessions#new", :as => "log_in"
  get "log_out" => "sessions#destroy", :as => "log_out"
  resources :sessions, :only => [:new, :create, :update, :destroy]

  get "sign_up" => "users#new", :as => "sign_up"
  resources :users, :only => [:new, :create]

end
