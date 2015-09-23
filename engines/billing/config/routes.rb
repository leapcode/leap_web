Rails.application.routes.draw do

  scope "(:locale)", :locale => CommonLanguages.match_available do
  match 'payments/new' => 'payments#new', :as => :new_payment
  match 'payments/confirm' => 'payments#confirm', :as => :confirm_payment
  #resources :users do
  #  resources :payments, :only => [:index]
  #  resources :subscriptions, :only => [:index, :destroy]
  #end

  resources :customer, :only => [:new, :edit]
  resources :credit_card_info, :only => [:edit]

  match 'customer/confirm/' => 'customer#confirm', :as => :confirm_customer
  match 'customer/show/:id' => 'customer#show', :as => :show_customer
  match 'credit_card_info/confirm' => 'credit_card_info#confirm', :as => :confirm_credit_card_info

  resources :subscriptions, :only => [:new, :create, :update] # index, show & destroy are within users path
  match 'billing_admin' => 'billing_admin#show', :as => :billing_admin
  match 'subscriptions/index' => 'subscriptions#index', :as => :index_subscription
  match 'subscriptions/show' => 'subscriptions#show', :as => :show_subscription
  end
end
