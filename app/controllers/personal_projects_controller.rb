class PersonalProjectsController < ApplicationController

  before_action :authenticate_volunteer!
  before_action :set_personal_project, only: [:edit, :update, :destroy]


  def new
    @personal_project = PersonalProject.new
  end


  def create
    @personal_project = PersonalProject.new personal_project_params
    @personal_project.volunteer = current_volunteer
    if @personal_project.save
      redirect_to( my_projects_url, notice: 'Personal project was created successfully' )
    else
      render :new
    end
  end


  def edit
    render :new
  end


  def update
    if @personal_project.update personal_project_params
      redirect_to my_projects_path, notice: 'Project was updated successfully'
    else
      render :new
    end
  end


  def destroy
    @personal_project.destroy
    redirect_to my_projects_url, notice: 'Project was deleted.'
  end



  private

    def set_personal_project
      @personal_project = PersonalProject.find(params[:id])
    end


    # Parameter white lists
    def personal_project_params
      params
        .require(:personal_project)
        .permit(
          :project_date,
          :volunteer_count,
          :duration,
          :description,
        )
    end

end
