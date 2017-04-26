class ApplicationController < ActionController::Base

  layout :layout

  protect_from_forgery with: :exception


  protected

    def after_sign_in_path_for(resource_or_scope)
      if resource.is_a?(User)
        admin_root_url
      else
        projects_index_url
      end
    end

    def after_sign_out_path_for(resource_or_scope)
      if resource_or_scope == :user
        admin_root_url
      else
        super
      end
    end


    def devise_parameter_sanitizer
      if resource_class == Volunteer
        Volunteer::ParameterSanitizer.new(Volunteer, :volunteer, params)
      else
        super # Use the default one
      end
    end


  private

    def layout
      if devise_controller? &&  resource_name == :user
        'devise'
      else
        'application'
      end
    end

end
