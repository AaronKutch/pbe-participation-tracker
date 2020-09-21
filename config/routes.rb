Rails.application.routes.draw do
  root 'login/index'
  get 'users/index'
  get 'users/create'
  get 'users/update'
  get 'users/dashboard'
  get 'events/index'
  get 'events/create'
  get 'events/update'
  get 'events/dashboard'

  
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
