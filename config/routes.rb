Rails.application.routes.draw do
  get "/health", to: "health#show"
  namespace :api do
    post "/score", to: "scores#create"
  end
  match "*path", to: "errors#not_found", via: :all
end
