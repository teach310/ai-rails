Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  namespace :api do
    namespace :toio do
      resources :cubes, only: [] do
        collection do
          post :lua
        end
      end
    end
  end
end
