class Admin::BaseController < ApplicationController

  layout 'admin'

  before_action :authenticate_user!

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to( { controller: 'home', action: 'not_authorized' } )
  end

end
