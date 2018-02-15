Rails.application.routes.draw do
  post '/tweet'  => 'home#tweet'

  root 'home#index'


  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
