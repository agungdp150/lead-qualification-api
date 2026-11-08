Rails.application.routes.draw do
  root to: "health#show"
  get "/health", to: "health#show"
  namespace :api do
    post "/score", to: "scores#create"
  end
  match "*path", to: "errors#not_found", via: :all
end
