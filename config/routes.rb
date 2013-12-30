LeapWeb::Application.routes.draw do
  #
  # Please do not use root_path or root_url. Use home_path and home_url instead,
  # so that the path will be correctly prefixed with the locale.
  #
  root :to => "home#index"
  get '(:locale)' => 'home#index', :locale => MATCH_LOCALE, :as => 'home'

  get '/provider.json' => 'static_config#provider'
end
