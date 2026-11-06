Rails.application.routes.draw do
  namespace :api do
    post "/password_resets" => "password_resets#create"
    patch "/password_resets" => "password_resets#update"
    get "/account" => "account#show"
    patch "/account" => "account#update"
    get "/contacts" => "contacts#index"
    post "/contacts" => "contacts#create"
    get "/contacts/:id" => "contacts#show"
    patch "/contacts/:id" => "contacts#update"
    delete "/contacts/:id" => "contacts#destroy"

    post "/users" => "users#create"

    post "/sessions" => "sessions#create"

    get "/reachouts" => "reachouts#index"
    post "/reachouts" => "reachouts#create"
    get "/reachouts/:id" => "reachouts#show"
    patch "/reachouts/:id" => "reachouts#update"
    delete "/reachouts/:id" => "reachouts#destroy"


    post 'twilio/status' => '/twilio#status'

  end

  get '/up', to: 'rails/health#show', as: :rails_health_check
  get '/health/ready', to: 'health#ready'
  root 'frontend#show'
  get '*path', to: 'frontend#show', constraints: ->(request) { !request.path.match?(%r{\A/(api|app|assets)(/|$)}) && request.format.html? }

end
