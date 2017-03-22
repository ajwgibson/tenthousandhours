Rails.application.routes.draw do

  root 'home#index'

  resources :projects

end
