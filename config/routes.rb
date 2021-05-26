Rails.application.routes.draw do
  devise_for :users, controllers: { sessions: 'sessions', passwords: 'passwords', confirmations: 'confirmations' }
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  resources :qr_codes do
    collection do
      get :verify
    end

    member do
      get :refreshed_code
    end
  end

  resource :user do
    collection do
      get :vaccinations
      get :share_info
      post :send_info
      get :accept_info
    end
  end

  resources :cr_groups do
    member do
      get :invite
      post :send_invite
      delete :leave
      delete :remove
    end
  end

  resources :cr_access, only: %i[new create update show] do
    member do
      get :success
      delete :unlink
      patch :update_pfp
    end
  end

  resources :cr_access_groups, only: %i[] do
    member do
      patch :process_invite
    end

    collection do
      get :accept_invite
    end
  end

  resource :history, only: %i[show] do
    post :share
    collection do
      get :certificate
    end
  end

  resources :shared_records, only: %i[show]

  root to: 'home#index'
end
