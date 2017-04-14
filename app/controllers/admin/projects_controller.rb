class Admin::ProjectsController < Admin::BaseController

  load_and_authorize_resource

  def index
    @filter = get_filter
    @projects = Project.filter(@filter).order :project_name
    set_filter @filter
  end


  def clear_filter
    set_filter nil
    redirect_to admin_projects_url
  end


  def print_list
    @filter = get_filter
    @projects = Project.filter(@filter).order :project_name
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
      redirect_to [:admin, @project], notice: 'Project was updated successfully'
    else
      render :edit
    end
  end


  def destroy
    @project.destroy
    redirect_to admin_projects_url, notice: 'Project was deleted.'
  end


  def review
  end


  def do_review
    @project.attributes = review_params
    if @project.save
      redirect_to [:admin, @project], notice: 'Project was updated successfully'
    else
      render :review
    end
  end


  def summary
  end


  def do_summary
    @project.attributes = summary_params
    @project.save
    redirect_to [:admin, @project], notice: 'Project summary was updated successfully'
  end


  def publish
  end


  def do_publish
    if @project.can_publish?
      @project.published!
      redirect_to [:admin, @project], notice: 'Project was published'
    else
      flash[:error] = 'Project cannot be published'
      redirect_to admin_publish_project_url(@project)
    end
  end


  private

    # Parameter white lists
    def project_params
      params
        .require(:project)
        .permit(
          :organisation_type,
          :project_name,
          :notes,
          :contact_name,
          :contact_role,
          :contact_email,
          :contact_phone,
          :activity_1_summary,
          :activity_1_information,
          :activity_1_under_18,
          :activity_2_summary,
          :activity_2_information,
          :activity_2_under_18,
          :activity_3_summary,
          :activity_3_information,
          :activity_3_under_18,
          :any_week,
          :evenings,
          :saturday,
          :july_3,
          :july_10,
          :july_17,
          :july_24,
          :adults,
          :youth,
          :materials,
        )
    end

    def summary_params
      params
        .require(:project)
        .permit(:summary)
    end

    def review_params
      params
        .require(:project)
        .permit(
          :activity_1_summary,
          :activity_1_information,
          :activity_1_under_18,
          :activity_2_summary,
          :activity_2_information,
          :activity_2_under_18,
          :activity_3_summary,
          :activity_3_information,
          :activity_3_under_18,
          :adults,
          :youth,
          :materials,
        )
    end

    def get_filter
      filter =
        params.slice(
          :could_run_wc_july_3rd,
          :could_run_wc_july_10th,
          :could_run_wc_july_17th,
          :could_run_wc_july_24th,
          :could_run_evenings,
          :could_run_saturday,
          :with_name,
          :of_type,
          :with_status,
          :order_by,
        )
      filter = session[:filter_projects].symbolize_keys! if filter.empty? && session.key?(:filter_projects)
      filter = { :order_by => 'project_name' } if filter.empty?
      filter.delete_if { |key, value| value.blank? }
    end

    def set_filter(filter)
      session[:filter_projects] = filter unless filter.nil?
      session.delete(:filter_projects) if filter.nil?
    end

end
