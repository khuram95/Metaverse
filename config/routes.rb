Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root to: 'accounts#index'
  resources :accounts
  resources :properties
  get '/expensive_properties', to: 'properties#most_expensive'
  get '/least_expensive', to: 'properties#least_expensive'
  get '/transactions', to: 'properties#transactions'
  get '/recent_listed', to: 'properties#recent_listed'
end
