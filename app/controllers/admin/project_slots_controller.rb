class Admin::ProjectSlotsController < Admin::BaseController

  load_and_authorize_resource  :ProjectSlot, :parent => false


  def index
    @project = Project.find(params['project_id'])
    @create_project_slot = CreateProjectSlot.new
  end


  def create
    @project = Project.find(params['project_id'])
    @create_project_slot = CreateProjectSlot.new model_params
    if @create_project_slot.valid?
      total = @create_project_slot.create_slots @project
      redirect_to( { action: 'index' }, notice: "#{total} #{'slot'.pluralize(total)} added")
    else
      render :index
    end
  end


  def destroy
    project = @ProjectSlot.project
    @ProjectSlot.destroy
    redirect_to admin_project_slots_url(project), notice: 'Slot was deleted.'
  end


  private

  def model_params
    params
      .require(:create_project_slot)
      .permit(
        :start_date,
        :end_date,
        :morning_slot,
        :afternoon_slot,
        :evening_slot
      )
  end

end
