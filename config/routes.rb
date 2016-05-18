LeapWeb::Application.routes.draw do
  #
  # Please do not use root_path or root_url. Use home_path and home_url instead,
  # so that the path will be correctly prefixed with the locale.
  #
  root :to => "home#index"
  get '(:locale)' => 'home#index', :locale => CommonLanguages.match_available, :as => 'home'

  #
  # HTTP Error Handling
  # instead of the default error pages use the errors controller and views
  #
  match '/404' => 'errors#not_found', via: [:get, :post]
  match '/500' => 'errors#server_error', via: [:get, :post]

  scope "(:locale)", :locale => CommonLanguages.match_available, :controller => 'pages', :action => 'show' do
    get 'privacy-policy', :as => 'privacy_policy'
    get 'terms-of-service', :as => 'terms_of_service'
    get 'about', :as => 'about'
    get 'contact', :as => 'contact'
    get 'pricing', :as => 'pricing'
    get 'bye', :as => 'bye'
  end

  get '/provider.json' => 'static_config#provider'

  namespace "api", { module: "api",
      path: "/:version/",
      defaults: {version: '2', format: 'json'},
      :constraints => { :id => /[^\/]+(?=\.json\z)|[^\/]+/, :version => /[12]/ }
      } do
    resources :sessions, :only => [:new, :create, :update]
    delete "logout" => "sessions#destroy", :as => "logout"
    resources :users, :only => [:create, :update, :destroy, :index, :show]
    resources :messages, :only => [:index, :update]
    resource :cert, :only => [:show, :create]
    resource :smtp_cert, :only => [:create]
    resource :service, :only => [:show]
    resources :configs, :only => [:index, :show]
    resources :identities, :only => [:show]
  end

  scope "(:locale)", :locale => CommonLanguages.match_available do
    get "login" => "sessions#new", :as => "login"
    delete "logout" => "sessions#destroy", :as => "logout"

    get "signup" => "users#new", :as => "signup"
    resources :users, :except => [:create, :update] do
      # resource :email_settings, :only => [:edit, :update]
      # resources :email_aliases, :only => [:destroy], :id => /.*/
      post 'deactivate', on: :member
      post 'enable', on: :member
    end

    resources :invite_codes, :only => [:index, :destroy, :create]
    resources :identities, :only => [:index, :destroy]
  end

  get "/.well-known/host-meta" => 'webfinger#host_meta'
  get "/webfinger" => 'webfinger#search'
  get "/key/:login" => 'keys#show'

end
