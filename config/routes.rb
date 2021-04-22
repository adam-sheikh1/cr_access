Rails.application.routes.draw do
  devise_for :users
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
    member do
      get :fv_code
    end

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
    end

    collection do
      get :accept_invite
    end
  end

  namespace :api do
    namespace :v1 do
      resources :patients, only: %i[] do
        collection do
          put :update_status
        end
      end
    end
  end

  root to: 'home#index'
end
