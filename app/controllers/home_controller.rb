class HomeController < ApplicationController

  def index
    @projects = Project.published.order(:project_name)
  end
  
end
