Rails.application.routes.draw do

  scope "(:locale)", :locale => CommonLanguages.match_available do

    get 'payments/new' => 'payments#new', :as => :new_payment
    post 'payments/confirm' => 'payments#confirm', :as => :confirm_payment
    #  match 'payments/new' => 'payments#new', :as => :new_payment
    #  match 'payments/confirm' => 'payments#confirm', :as => :confirm_payment
    #resources :users do
    # resources :payments, :only => [:new, :confirm]
    #  resources :subscriptions, :only => [:index, :destroy]
    #end
    resources :subscriptions, :only => [:index, :show] do
      member do
        post 'subscribe'
        delete 'unsubscribe'
      end
    end

    resources :customer, :only => [:new, :edit]

    get 'billing_admin' => 'billing_admin#show'
  end
end
