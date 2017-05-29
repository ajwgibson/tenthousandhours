class Admin::VolunteersController < Admin::BaseController

  load_and_authorize_resource


  def index
    @volunteers = Volunteer.all
  end


  def show
  end


  def compose_message
    @ComposeMessage = ComposeMessage.new
  end


  def send_message
    @ComposeMessage = ComposeMessage.new(compose_message_params)
    if @ComposeMessage.valid?
      TextLocalService.send_message(@ComposeMessage.message_text, @volunteer.mobile_international_format)
      redirect_to admin_volunteer_url(@volunteer), notice: 'Message sent'
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

end
