Rails.application.routes.draw do
  scope "(:locale)", locale: CommonLanguages.match_available do

    resources :tickets, except: :edit do
      member do
        patch 'open'
        patch 'close'
      end
    end

    resources :users do
      resources :tickets, except: :edit
    end

  end
end
