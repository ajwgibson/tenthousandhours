class ProjectsController < ApplicationController

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


  private
    def set_project
      @project = Project.find(params[:id])
    end

end
