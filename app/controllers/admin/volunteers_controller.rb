class Admin::VolunteersController < Admin::BaseController

  load_and_authorize_resource


  def index
    @volunteers = Volunteer.all
  end


  def show
  end


  def compose_one
    @ComposeMessage = ComposeMessage.new
  end


  def send_one
    @ComposeMessage = ComposeMessage.new(compose_message_params)
    if @ComposeMessage.valid?
      TextLocalService.send_message(@ComposeMessage.message_text, @volunteer.mobile_international_format)
      redirect_to admin_volunteer_url(@volunteer), notice: 'Message sent'
    else
      render :compose_one
    end
  end


  def compose_all
    @volunteer_count = Volunteer.count
    @ComposeMessage = ComposeMessage.new
  end


  def send_all
    @ComposeMessage = ComposeMessage.new(compose_message_params)
    if @ComposeMessage.valid?
      numbers = Volunteer.all.collect { |v| v.mobile_international_format }
      TextLocalService.send_message(@ComposeMessage.message_text, numbers)
      redirect_to admin_volunteers_url, notice: 'Message sent'
    else
      @volunteer_count = Volunteer.count
      render :compose_all
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

end
