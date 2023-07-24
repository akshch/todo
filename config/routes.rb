Rails.application.routes.draw do

  devise_for :users
  scope "/admin" do
    resources :users
  end

  resources :tickets do
    member do
      post 'process_csv'
      put 'set_status'
    end
    get 'generate_csv_data', on: :collection
    resources :comments
  end
  root 'tickets#index'
end
