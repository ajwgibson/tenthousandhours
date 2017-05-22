Rails.application.routes.draw do

  root 'home#index'

  get  'home/my_projects', :as => 'my_projects'

  resources :personal_projects, :except => [:index, :show]

  devise_for :volunteers, controllers: { registrations: "registrations" }
  devise_scope :volunteer do
    get  'volunteers/confirm_mobile' => 'registrations#confirm_mobile'
    post 'volunteers/confirm_mobile' => 'registrations#do_confirm_mobile', as: 'do_confirm_mobile'
  end

  get 'projects/index'
  get 'projects/clear_filter'
  post 'projects/volunteer', as: 'volunteer_for_project'
  post 'projects/decline',   as: 'decline_from_project'

  scope '/admin' do
    devise_for :users
    as :user do
      get 'users/edit' => 'devise/registrations#edit', :as => 'edit_user_registration'
      put 'users' => 'devise/registrations#update', :as => 'user_registration'
    end
  end

  namespace :admin do

    root 'home#index'

    resources  :users
    resources  :volunteers
    resources  :text_messages

    get '/not_authorized', to: 'home#not_authorized'

    get  'projects/print_list',  as: 'print_project_list'
    get  'projects/clear_filter'
    get  'projects/import'
    post 'projects/import',      to: 'projects#do_import'
    get  'projects/:id/review',  to: 'projects#review',     as: 'review_project'
    put  'projects/:id/review',  to: 'projects#do_review'
    get  'projects/:id/summary', to: 'projects#summary',    as: 'summarise_project'
    put  'projects/:id/summary', to: 'projects#do_summary', as: 'do_summarise_project'
    get  'projects/:id/publish', to: 'projects#publish',    as: 'publish_project'
    put  'projects/:id/publish', to: 'projects#do_publish', as: 'do_publish_project'
    put  'projects/:id/unpublish', to: 'projects#do_unpublish', as: 'do_unpublish_project'
    resources :projects do
      get    'slots', to: 'project_slots#index',   as: 'slots'
      post   'slots', to: 'project_slots#create',  as: 'slots_create'
    end

    get    'project_slots/:id', to: 'project_slots#show',   as: 'show_project_slot'
    delete 'project_slots/:id', to: 'project_slots#destroy'

    get  'project_slots/:id/compose_message', to: 'project_slots#compose_message', as: 'compose_message_project_slot'
    post 'project_slots/:id/send_message',    to: 'project_slots#send_message',    as: 'send_message_project_slot'

  end

end
