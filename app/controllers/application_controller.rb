class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # Authenticate with Devise
  before_action :authenticate_user!

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to( { controller: 'home', action: 'not_authorized' } )
  end

end
