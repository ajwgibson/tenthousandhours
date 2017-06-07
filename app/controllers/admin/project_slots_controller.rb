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


  def show
  end


  def print
  end


  def compose_message
    @ComposeMessage = ComposeMessage.new
  end


  def send_message
    @ComposeMessage = ComposeMessage.new(compose_message_params)
    if @ComposeMessage.valid?
      numbers = @ProjectSlot.volunteers.collect { |v| v.mobile_international_format }
      TextLocalService.send_message(@ComposeMessage.message_text, numbers)
      redirect_to admin_show_project_slot_url(@ProjectSlot), notice: 'Message sent'
    else
      render :compose_message
    end
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

  def compose_message_params
    params
      .require(:compose_message)
      .permit(
        :message_text
      )
  end

end
