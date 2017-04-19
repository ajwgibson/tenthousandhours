class HomeController < ApplicationController

  layout 'landing'

  def index
    @projects = Project.published.order(:project_name)
  end

end
