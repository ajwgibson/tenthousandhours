class RegistrationsController < Devise::RegistrationsController


  protected

  def after_sign_up_path_for(resource)
    new_volunteer_session_path
  end

  def after_inactive_sign_up_path_for(resource)
    new_volunteer_session_path
  end

  def after_update_path_for(resource)
    projects_index_url
  end

end
