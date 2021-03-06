Rails.application.routes.draw do

  # Devise
  devise_scope :user do

    # Using `scope` for a shortcut
    scope '/users' do
      post 'resend_code' => 'users/registrations#resend_code'
      post 'verify_code' => 'users/registrations#verify_code'
    end
  end

  
  devise_for :users, controllers: {
               registrations: 'users/registrations'
             }
  ###

  # Admin
  scope '/admin' do
    get 'user_search' => 'admin#user_search'
    put 'verify/:user_id' => 'admin#verify', as: 'admin_verify'
    put 'promote/:user_id' => 'admin#promote', as: 'admin_promote'
    put 'demote/:user_id' => 'admin#demote', as: 'admin_demote'
    put 'restore/:user_id' => 'admin#restore_user', as: 'admin_restore_user'
    delete 'user/:user_id' => 'admin#destroy_user', as: 'admin_destroy_user'
  end
  ###

  # Home
  root 'home#index'
  get 'dashboard' => 'home#dashboard'
  get 'about' => 'home#about'
  ###

  resources :forums, only: [ :index, :show ] do
    collection do
      get :search
    end
    
    member do
      get :children
      get :all_posts
    end

    resources :posts, only: [ :index, :new, :create ]
  end

  resources :posts, only: [ :show, :edit, :update, :destroy ] do
    put 'vote/:value' => 'posts#vote', as: 'vote'
    put :approve

    resources :comments, only: [ :create ]
  end

  resources :comments, only: [ :edit, :update, :destroy ] do
    put 'vote/:value' => 'comments#vote', as: 'vote'
  end
end
