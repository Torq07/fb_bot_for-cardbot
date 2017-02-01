Rails.application.routes.draw do
  get 'users/new'

  get 'users/create'

	resources :users
  mount Facebook::Messenger::Server, at: 'bot'
end
