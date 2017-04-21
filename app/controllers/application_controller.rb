class ApplicationController < ActionController::Base

  layout :layout_by_resource

  protect_from_forgery with: :exception


  protected

    def after_sign_in_path_for(resource_or_scope)
      projects_index_url
    end


    def devise_parameter_sanitizer
      if resource_class == Volunteer
        Volunteer::ParameterSanitizer.new(Volunteer, :volunteer, params)
      else
        super # Use the default one
      end
    end


  private

    def layout_by_resource
      if devise_controller? &&  resource_name == :user
        'devise'
      else
        'application'
      end
    end

end
