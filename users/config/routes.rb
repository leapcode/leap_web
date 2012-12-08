Rails.application.routes.draw do

  scope "/1", :module => "V1", defaults: {format: 'json'} do
    resources :sessions, :only => [:new, :create, :update, :destroy]
    resources :users, :only => [:create]
  end

  get "login" => "sessions#new", :as => "login"
  get "logout" => "sessions#destroy", :as => "logout"
  resources :sessions, :only => [:new, :create, :update, :destroy]

  get "signup" => "users#new", :as => "signup"
  resources :users

end
