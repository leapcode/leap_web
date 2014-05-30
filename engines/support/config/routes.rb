Rails.application.routes.draw do
  scope "(:locale)", locale: MATCH_LOCALE do

    resources :tickets, except: :edit do
      member do
        put 'open'
        put 'close'
      end
    end

    resources :users do
      resources :tickets, except: :edit
    end

  end
end
