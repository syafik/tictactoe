Rails.application.routes.draw do
  devise_for :users

  devise_scope :user do
    get '/users/sign_out' => 'devise/sessions#destroy'
  end

  resources :games do
    member do
      get :join
      post :play
      get :start
      get :move
      post :submit_move
      get :reset_board
    end
  end
  # Defines the root path route ("/")
  root 'games#index'
end
