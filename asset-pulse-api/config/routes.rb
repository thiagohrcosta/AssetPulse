Rails.application.routes.draw do
  # Swagger UI + the raw spec it reads (swagger/v1/swagger.yaml, hand-written
  # — see that file's header for why there's no rswag-specs/RSpec involved).
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'

  devise_for :users

  get "up" => "rails/health#show", as: :rails_health_check

  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  get "api/health" => "api/health#status", as: :api_health_status

  namespace :api do
    namespace :v1 do
      post "auth/register", to: "auth#register"
      post "auth/login", to: "auth#login"

      resources :companies, only: [:index, :show, :create, :update, :destroy] do
        resource :subscription, only: [:show], controller: "subscriptions" do
          post :trial
          post :checkout_session
          post :billing_portal
        end

        resources :host_units
        resources :parts do
          resources :lifecycle_events
        end
      end

      resources :part_type_references

      get "plans", to: "plans#index"

      namespace :stripe do
        post "webhooks", to: "webhooks#create"
      end
    end
  end


  # Defines the root path route ("/")
  # root "posts#index"
end
