class ProjectsController < ApplicationController

  before_action :set_project, only: [:show, :edit, :update, :destroy]

  def index
    @projects = Project.all
  end


  def import
    @file_upload = FileUpload.new
  end


  def do_import
    @file_upload = FileUpload.new(params[:file_upload])
    if @file_upload.valid?
      uploaded_io = params[:file_upload][:filename]
      filename = @file_upload.upload_file(uploaded_io)
      begin
        Project.import(filename)
        redirect_to( { action: 'index' }, notice: 'Import completed successfully.')
      rescue
        @file_upload.errors.add(:data_file, 'contained invalid data. Please try again')
        flash[:error] = 'Import failed'
        render 'import'
      end
    else
      render 'import'
    end
  end


  def show
  end


  def new
    @project = Project.new
    render :edit
  end


  def create
    @project = Project.new project_params
    @project.submitted_at = DateTime.now
    if @project.save
      redirect_to( { action: 'index' }, notice: 'Project was created successfully' )
    else
      render :edit
    end
  end


  def edit
  end


  def update
    @project.attributes = project_params
    if @project.save project_params
      redirect_to @project, notice: 'Project was updated successfully'
    else
      render :edit
    end
  end



  private
    def set_project
      @project = Project.find(params[:id])
    end

    # Parameter white list
    def project_params
      params
        .require(:project)
        .permit(
          :organisation_type,
          :organisation_name,
          :notes,
          :contact_name,
          :contact_role,
          :contact_email,
          :contact_phone,
          :project_1_summary,
          :project_1_information,
          :project_1_under_18,
          :project_2_summary,
          :project_2_information,
          :project_2_under_18,
          :project_3_summary,
          :project_3_information,
          :project_3_under_18,
          :any_week,
          :evenings,
          :saturday,
          :july_3,
          :july_10,
          :july_17,
          :july_24,
        )
    end

end
