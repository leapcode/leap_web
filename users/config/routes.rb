Rails.application.routes.draw do

  get "login" => "sessions#new", :as => "login"
  get "logout" => "sessions#destroy", :as => "logout"
  resources :sessions, :only => [:new, :create, :update, :destroy]

  get "signup" => "users#new", :as => "signup"
  resources :users

end
