Rails.application.routes.draw do

  root 'home#index'

  get  'projects/import'
  post 'projects/import', to: 'projects#do_import'
  resources :projects

end
