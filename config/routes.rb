Rails.application.routes.draw do

  devise_for :users
  resources  :users

  root 'home#index'

  get '/not_authorized', to: 'home#not_authorized'

  get  'projects/import'
  post 'projects/import', to: 'projects#do_import'
  get  'projects/:id/review', to: 'projects#review',    as: 'review_project'
  put  'projects/:id/review', to: 'projects#do_review'
  resources :projects do
    get    'slots', to: 'project_slots#index',   as: 'slots'
    post   'slots', to: 'project_slots#create',  as: 'slots_create'
  end
  delete 'project_slots/:id', to: 'project_slots#destroy'

end
