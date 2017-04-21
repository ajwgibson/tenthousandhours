class Volunteer::ParameterSanitizer < Devise::ParameterSanitizer

  def sign_up
    default_params.permit(volunteer_params)
  end

  def account_update
    default_params.permit(volunteer_params << :current_password)
  end


  private

  def volunteer_params
    [
      :email, :password, :password_confirmation,
      :first_name, :last_name, :mobile, :age_category,
      :family,
      { skills: [] }]
  end

end
