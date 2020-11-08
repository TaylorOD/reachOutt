Rails.application.routes.draw do
  # EXAMPLE HTML ROUTE
  # get "/photos" => "photos#index"

  # EXAMPLE JSON ROUTE WITH API NAMESPACE
  namespace :api do
    get "/contacts" => "contacts#index"
    post "/contacts" => "contacts#create"
    get "/contacts/:id" => "contacts#show"
    patch "/contacts/:id" => "contacts#update"
    delete "/contacts/:id" => "contacts#destory"

    post "/users" => "users#create"

    post "/sessions" => "sessions#create"

    get "/reachouts" => "reachouts#index"
    post "/reachouts" => "reachouts#create"
    get "/reachouts/:id" => "reachouts#show"
    patch "/reachouts/:id" => "reachouts#update"
    delete "/reachouts/:id" => "reachouts#destroy"

    post "notifications/notify" => "notifications#notify"
  end
end
