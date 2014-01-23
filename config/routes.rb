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
end
