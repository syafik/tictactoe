Rails.application.routes.draw do
  devise_for :users, controllers: { sessions: 'users/sessions', registrations: 'users/registrations' }

  devise_scope :user do
    get '/users/sign_out' => 'devise/sessions#destroy'
  end

  resources :games do
    member do
      get :join
      get :play
      get :start
      get :move
      post :submit_move
      get :reset_board
    end
  end
  # Defines the root path route ("/")
  root 'games#index'
end
