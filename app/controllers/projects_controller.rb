class ProjectsController < ApplicationController

  def index
    @projects = Project.all
  end

  private
    def set_project
      @project = Project.find(params[:id])
    end

end
