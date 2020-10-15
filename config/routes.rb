# frozen_string_literal: true

Rails.application.routes.draw do
  root 'access#login'

  get 'access/login'
  get 'access/logout'
  get 'access/new_account'
  post 'access/create_account'
  post 'access/attempt_login'

  post 'events/mark_attendance'
  post 'events/revoke_attendence'
  resources :events do
    member do
      get :delete
    end
  end

  resources :users, except: :create do
    member do
      get :delete
    end
  end

  post 'events/:event_id/manual_add/:user_id' => 'events#manual_add', as: 'events_manual_add'

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
