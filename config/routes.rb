LeapWeb::Application.routes.draw do
  #
  # Please do not use root_path or root_url. Use home_path and home_url instead,
  # so that the path will be correctly prefixed with the locale.
  #
  root :to => "home#index"
  get '(:locale)' => 'home#index', :locale => MATCH_LOCALE, :as => 'home'

  scope "(:locale)", :locale => MATCH_LOCALE, :controller => 'pages', :action => 'show' do
    get 'privacy-policy', :as => 'privacy_policy'
    get 'terms-of-service', :as => 'terms_of_service'
    get 'about', :as => 'about'
    get 'contact', :as => 'contact'
    get 'pricing', :as => 'pricing'
    get 'bye', :as => 'bye'
  end

  get '/provider.json' => 'static_config#provider'

  namespace "api", { module: "v1",
      path: "/1/",
      defaults: {format: 'json'} } do
    resources :sessions, :only => [:new, :create, :update],
      :constraints => { :id => /[^\/]+(?=\.json\z)|[^\/]+/ }
    delete "logout" => "sessions#destroy", :as => "logout"
    resources :users, :only => [:create, :update, :destroy, :index]
    resources :messages, :only => [:index, :update]
    resource :cert, :only => [:show, :create]
    resource :smtp_cert, :only => [:create]
    resource :service, :only => [:show]
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
