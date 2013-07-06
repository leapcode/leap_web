Rails.application.routes.draw do
  resources :tickets, :except => :edit
  resources :users do
    resources :tickets, :except => :edit
  end
end
