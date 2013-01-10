Rails.application.routes.draw do

  constraints :subdomain => "api" do
    namespace "api", :path => nil do
      scope "/1", :module => "V1", defaults: {format: 'json'} do
        resources :sessions, :only => [:new, :create, :update, :destroy]
        resources :users, :only => [:create]
      end
    end
  end

  get "login" => "sessions#new", :as => "login"
  get "logout" => "sessions#destroy", :as => "logout"
  resources :sessions, :only => [:new, :create, :update, :destroy]

  get "signup" => "users#new", :as => "signup"
  resources :users do
    resources :email_aliases, :only => [:destroy], :id => /.*/
  end

end
