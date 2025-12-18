Rails.application.routes.draw do
  root 'recommendations#index'
  
  resources :recommendations, only: [:index, :create] do
    member do
      get :click
    end
  end
end
