Rails.application.routes.draw do

  devise_for :users
  resources  :users

  root 'home#index'

  get  'projects/import'
  post 'projects/import', to: 'projects#do_import'
  resources :projects

end
