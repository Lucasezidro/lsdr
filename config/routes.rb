Rails.application.routes.draw do
  resources :users, only: [:create, :show, :update, :destroy] do
    member do
      patch :accept_invitation
    end
  end

  post '/auth/login', to: 'authentication#login'
  get '/accept_invitation', to: 'users#accept_invitation'
  get '/me', to: 'users#me'

  resources :organizations, only: [:index, :show, :create, :update, :destroy] do
    post :invite, on: :member
    get :members, on: :member

    resources :goals, only: [:index, :create, :update, :destroy]
  end

  resources :addresses, only: [:index, :show, :create, :update, :destroy]
end