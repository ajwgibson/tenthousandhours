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
  get 'projects/:id',  to: 'projects#show', as: 'show_project'
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

    get  'text_messages/clear_filter'
    resources  :text_messages

    get  'volunteers/compose_all', to: 'volunteers#compose_all', as: 'compose_all_volunteers'
    post 'volunteers/send_all',    to: 'volunteers#send_all',    as: 'send_all_volunteers'
    get  'volunteers/clear_filter'
    resources  :volunteers do
      member do
        get  'compose_one'
        post 'send_one'
        get  'new_sign_up'
        post 'create_sign_up'
      end
    end

    delete 'decline/:id', to: 'volunteers#decline', as: 'decline_volunteer_serve'

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
    get  'projects/:id/compose_message', to: 'projects#compose_message', as: 'compose_message_project'
    post 'projects/:id/send_message',    to: 'projects#send_message', as: 'send_message_project'
    resources :projects do
      get    'slots', to: 'project_slots#index',   as: 'slots'
      post   'slots', to: 'project_slots#create',  as: 'slots_create'
    end
    delete 'project_slots/:id',       to: 'project_slots#destroy'

    resources :slots do
      collection do
        get 'clear_filter'
      end
      member do
        get  'print'
        get  'compose_message'
        post 'send_message'
      end
    end

  end

  get 'notifications/reminders', to: 'notifications#reminders', constraints: { local?: true  }

end
