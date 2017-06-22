class Admin::SlotsController < Admin::BaseController

  load_and_authorize_resource  :ProjectSlot, :parent => false


  def index
    @filter = get_filter
    @slots = ProjectSlot.includes(:project).filter(@filter).order(:slot_date, :slot_type)
    @slots = @slots.page params[:page]
    set_filter @filter
  end


  def clear_filter
    set_filter nil
    redirect_to admin_slots_url
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
      redirect_to admin_slot_url(@ProjectSlot), notice: 'Message sent'
    else
      render :compose_message
    end
  end


private

  def compose_message_params
    params
      .require(:compose_message)
      .permit(
        :message_text
      )
  end


  def get_filter
    filter =
      params.slice(
        :with_project_name,
        :for_week,
        :for_date,
        :of_type,
        :order_by,
      )
    filter = session[:filter_admin_slots].symbolize_keys! if filter.empty? && session.key?(:filter_admin_slots)
    filter = { :order_by => 'projects.project_name' } if filter.empty?
    filter.delete_if { |key, value| value.blank? }
  end


  def set_filter(filter)
    session[:filter_admin_slots] = filter unless filter.nil?
    session.delete(:filter_admin_slots) if filter.nil?
  end

end
