Rails.application.routes.draw do
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
