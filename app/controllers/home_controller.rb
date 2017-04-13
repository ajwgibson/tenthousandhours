class HomeController < ApplicationController

  def index
    @projects = Project.published.order(:organisation_name)
  end
  
end
