Rails.application.routes.draw do
  root "pages#home"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Génération de toutes les routes nécessaires pour :user
  devise_for :users

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"

  # ---- NAMESPACE ADMIN ----
  namespace :admin do
    root to: "dashboard#index"

    resources :users
    resources :people do
      resources :mandates, only: %i[index new create edit]
    end

    resources :institutions do
      resources :mandates, only: %i[index new create edit]
    end

    resources :political_groups
    resources :constituencies

    resources :mandates do
      resources :compensations
      resources :attendances
      resources :assets
    end

    resources :sources
  end

  # ---- NAMESPACE PUBLIC ----
  # Ici scope module: :public supprime le préfic d'URL mais garde le module contrôleur
  # ex -> /elus/emmanuel-macron et pas /public/elus/emmanuel-macron
  scope module: :public do
    resources :people, only: %i[index show], path: "elus"
    resources :institutions, only: %i[index show]
    resources :political_groups, only: %i[index show]
    resources :constituencies, only: %i[index show]
    resources :mandates, only: %i[show]
  end

  # ---- API ----
  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :people, only: %i[index show]
      resources :institutions, only: %i[index show]
      resources :political_groups, only: %i[index show]
      resources :constituencies, only: %i[index show]
      resources :mandates, only: %i[index show]
    end
  end
end
