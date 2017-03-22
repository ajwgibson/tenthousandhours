Rails.application.routes.draw do

  root 'home#index'

  get 'projects/import'
  resources :projects

end
