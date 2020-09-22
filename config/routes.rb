Rails.application.routes.draw do
  root 'events#index'

  get 'admin', :to => 'access#menu'
  get 'access/menu'
  get 'access/login'
  post 'access/attempt_login'
  get 'access/logout'

  post 'events/mark_attendance'

  #get 'events/index'
  #get 'events/show'
  #get 'events/new'
  #get 'events/edit'
  #get 'events/delete'
  
	resources :events do

		member do
			get :delete
		end

	end

# For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
