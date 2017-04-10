Rails.application.routes.draw do

  devise_for :users
  resources  :users

  root 'home#index'

  get '/not_authorized', to: 'home#not_authorized'

  get  'projects/clear_filter'
  get  'projects/import'
  post 'projects/import',      to: 'projects#do_import'
  get  'projects/:id/review',  to: 'projects#review',     as: 'review_project'
  put  'projects/:id/review',  to: 'projects#do_review'
  get  'projects/:id/summary', to: 'projects#summary',    as: 'summarise_project'
  put  'projects/:id/summary', to: 'projects#do_summary', as: 'do_summarise_project'
  get  'projects/:id/publish', to: 'projects#publish',    as: 'publish_project'
  put  'projects/:id/publish', to: 'projects#do_publish', as: 'do_publish_project'
  resources :projects do
    get    'slots', to: 'project_slots#index',   as: 'slots'
    post   'slots', to: 'project_slots#create',  as: 'slots_create'
  end

  delete 'project_slots/:id', to: 'project_slots#destroy'

end
