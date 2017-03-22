class ProjectsController < ApplicationController

  def index
    @projects = Project.all
  end


  def import
    @file_upload = FileUpload.new
  end

  private
    def set_project
      @project = Project.find(params[:id])
    end

end
