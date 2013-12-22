Rails.application.routes.draw do

  namespace "api", { module: "v1",
      path: "/1/",
      defaults: {format: 'json'} } do
    resources :sessions, :only => [:new, :create, :update]
    delete "logout" => "sessions#destroy", :as => "logout"
    resources :users, :only => [:create, :update, :destroy, :index]
  end

  scope "(:locale)", :locale => MATCH_LOCALE do
    get "login" => "sessions#new", :as => "login"
    delete "logout" => "sessions#destroy", :as => "logout"

    get "signup" => "users#new", :as => "signup"
    resources :users, :except => [:create, :update] do
      # resource :email_settings, :only => [:edit, :update]
      # resources :email_aliases, :only => [:destroy], :id => /.*/
      post 'deactivate', on: :member
      post 'enable', on: :member
    end
  end

  get "/.well-known/host-meta" => 'webfinger#host_meta'
  get "/webfinger" => 'webfinger#search'
  get "/key/:login" => 'keys#show'

end
