Rails.application.routes.draw do
  root "dashboard#index"

  get "dashboard", to: "dashboard#index"
  resources :test_cases
  resources :test_suites do
    member do
      post :add_test_case
      delete :remove_test_case
    end
  end
  resources :test_runs do
    member do
      patch :execute_test
    end
  end
  resources :junit_uploads, except: [ :edit, :update ]

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
