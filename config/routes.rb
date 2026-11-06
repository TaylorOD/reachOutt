Rails.application.routes.draw do
  namespace :api do
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
  root 'frontend#show'
  get '*path', to: 'frontend#show', constraints: ->(request) { !request.path.start_with?('/api/', '/assets/') && request.format.html? }

  # match "*path", to: proc { [404, {}, [File.read(Rails.root.join('public', '404.html'))]] }, via: :all
end
