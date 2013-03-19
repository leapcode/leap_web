Rails.application.routes.draw do

  match 'payments/new' => 'payments#new', :as => :new_payment
  match 'payments/confirm' => 'payments#confirm', :as => :confirm_payment

  resources :customer, :only => [:new, :edit]
  resources :credit_card_info, :only => [:edit]

  match 'customer/confirm' => 'customer#confirm', :as => :confirm_customer
  match 'credit_card_info/confirm' => 'credit_card_info#confirm', :as => :confirm_credit_card_info
  #match 'transactions/:product_id/new' => 'transactions#new', :as => :new_transaction
  #match 'transactions/confirm/:product_id' => 'transactions#confirm', :as => :confirm_transaction


end
