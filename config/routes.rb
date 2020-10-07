# frozen_string_literal: true

Rails.application.routes.draw do
  root 'access#login'
  # Routes will be used in sprint 2
  get 'access/login'
  get 'access/logout'
  get 'access/new_account'
  post 'access/create_account'
  post 'access/attempt_login'

  post 'events/mark_attendance'
  resources :events do
    member do
      get :delete
    end
  end
  
  resources :users do
    member do
      get :delete
    end
  end

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
