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

    post "twilio/voice" => "twilio#voice"
  
    post 'twilio/status' => 'twilio#status'

    post "notifications/notify" => "notifications#notify"
  end
  
  get "/*path" => proc { [200, {}, [ActionView::Base.new.render(file: 'public/index.html')]] } 

end
