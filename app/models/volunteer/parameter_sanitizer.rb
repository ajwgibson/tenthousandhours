class Volunteer::ParameterSanitizer < Devise::ParameterSanitizer

  def initialize(*)
    super
    permit(:sign_up,        keys: volunteer_params)
    permit(:account_update, keys: volunteer_params << :current_password)
  end



  private

    def volunteer_params
      [
        :email, :password, :password_confirmation,
        :first_name, :last_name, :mobile, :age_category,
        :guardian_name, :guardian_contact_number,
        :family,
        :extra_adults, :extra_youth, :extra_children,
        { skills: [] }
      ]
    end

end
