Rails.application.routes.draw do
  root 'db_test#index'
  get 'db_test/index'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
