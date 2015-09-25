Rails.application.routes.draw do

  scope "(:locale)", :locale => CommonLanguages.match_available do
  match 'payments/new' => 'payments#new', :as => :new_payment
  match 'payments/confirm' => 'payments#confirm', :as => :confirm_payment
  #resources :users do
  #  resources :payments, :only => [:index]
  #  resources :subscriptions, :only => [:index, :destroy]
  #end
  resources :subscriptions, :only => [:index, :show] do
    member do
      post 'subscribe'
      delete 'unsubscribe'
    end
  end

  resources :customer, :only => [:new, :edit]

  match 'customer/confirm/' => 'customer#confirm', :as => :confirm_customer
  match 'customer/show/:id' => 'customer#show', :as => :show_customer

  match 'billing_admin' => 'billing_admin#show', :as => :billing_admin
  end
end
