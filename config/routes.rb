Rails.application.routes.draw do

  devise_for :users
  resources  :users

  root 'home#index'

  get '/not_authorized', to: 'home#not_authorized'

  get  'projects/import'
  post 'projects/import', to: 'projects#do_import'
  resources :projects

end
