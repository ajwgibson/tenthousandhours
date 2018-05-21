class RegistrationsController < Devise::RegistrationsController


  def confirm_mobile
  end


  def do_confirm_mobile
    @code = params[:code]
    if current_volunteer.mobile_confirmation_code == @code
      current_volunteer.mobile_confirmation_code = nil
      current_volunteer.save
      redirect_to my_projects_url, notice: 'Mobile number confirmed'
    else
      @error = 'Failed to match code - please try again'
      flash[:error] = 'Failed to match code'
      render :confirm_mobile
    end
  end


  protected

    def after_inactive_sign_up_path_for(resource)
      new_volunteer_session_path
    end

    def after_update_path_for(resource)
      my_projects_url
    end

end
