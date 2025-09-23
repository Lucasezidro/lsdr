Rails.application.routes.draw do
  get "password_resets/new"
  get "password_resets/create"
  resources :users do
    patch :assign_manager, on: :member
    get :my_employees, on: :collection
    resource :address, only: [:create, :show, :update, :destroy]
  end
  resources :users, only: [:index, :create, :show, :update, :destroy] do
    member do
      patch :accept_invitation
      patch :revoke_invitation
    end
  end

  post '/auth/login', to: 'authentication#login'
  get '/accept_invitation', to: 'users#accept_invitation'
  get '/me', to: 'users#me'

  resources :organizations, only: [:index, :show, :create, :update, :destroy] do
    post :invite, on: :member
    get :members, on: :member
    get :dashboard, on: :member

    resources :goals, only: [:index, :show, :create, :update, :destroy]
    resources :transactions, only: [:index, :create, :destroy, :update]

    member do
      patch 'members/:member_id', to: 'organizations#update_member_role'
      delete 'members/:member_id', to: 'organizations#remove_member'
    end
  end

  resources :addresses, only: [:index, :show, :create, :update, :destroy]

  resources :password_resets, only: [:create, :update]
  get '/password_resets/:token', to: 'password_resets#edit', as: :password_reset_edit

  post '/chat', to: 'chat#chat'
end