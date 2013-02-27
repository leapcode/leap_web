Rails.application.routes.draw do

  constraints :subdomain => "api" do
    namespace "api", { module: "v1",
        path: "/1/",
        defaults: {format: 'json'} } do
      resources :sessions, :only => [:new, :create, :update]
      delete "logout" => "sessions#destroy", :as => "logout"
      resources :users, :only => [:create, :update]
    end
  end

  get "login" => "sessions#new", :as => "login"
  delete "logout" => "sessions#destroy", :as => "logout"
  resources :sessions, :only => [:new, :create, :update]

  get "signup" => "users#new", :as => "signup"
  resources :users do
    resources :email_aliases, :only => [:destroy], :id => /.*/
  end

  get "/.well-known/host-meta" => 'webfinger#host_meta'
  get "/webfinger" => 'webfinger#search'
end
