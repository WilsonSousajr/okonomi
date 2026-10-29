Rails.application.routes.draw do
  resource :session
  resource :registration, only: %i[ new create ]
  resources :projects do
    resource :product_backlog, only: %i[ new create edit update destroy ]
    resources :sprint_backlogs, except: :index
    resources :user_stories, except: :index do
      resources :acceptance_criteria, except: %i[ index show ]
      resource :move, only: :create, controller: "user_story_moves"
    end
    resources :epics, except: :index
  end
  resources :passwords, param: :token
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Rota raiz. O concern Authentication redireciona para `root_url`
  # após a autenticação, então ela precisa existir (#21).
  root "home#index"
end
