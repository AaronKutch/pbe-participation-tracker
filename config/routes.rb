# frozen_string_literal: true

Rails.application.routes.draw do
  root 'access#login'
  # Routes will be used in sprint 2
  # get 'users/index'
  # get 'users/create'
  # get 'users/update'
  # get 'users/dashboard'

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  # root 'events#index'

  get 'access/login'
  post 'access/attempt_login'
  get 'access/logout'

  post 'events/mark_attendance'
  post 'events/revoke_attendence'
  resources :events do
    member do
      get :delete
    end
  end

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
