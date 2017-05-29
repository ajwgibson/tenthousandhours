class Admin::VolunteersController < Admin::BaseController

  load_and_authorize_resource


  def index
    @filter = get_filter
    @volunteers = Volunteer.filter(@filter).order(:first_name,:last_name)
    @volunteers = @volunteers.page params[:page]
    set_filter @filter
  end


  def clear_filter
    set_filter nil
    redirect_to admin_volunteers_url
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


  def get_filter
    filter =
      params.slice(
        :with_first_name,
        :with_last_name,
        :with_email,
        :with_mobile,
        :with_skill,
        :in_age_category,
        :order_by,
      )
    filter = session[:filter_admin_volunteers].symbolize_keys! if filter.empty? && session.key?(:filter_admin_volunteers)
    filter = { :order_by => 'first_name,last_name' } if filter.empty?
    filter.delete_if { |key, value| value.blank? }
  end


  def set_filter(filter)
    session[:filter_admin_volunteers] = filter unless filter.nil?
    session.delete(:filter_admin_volunteers) if filter.nil?
  end

end
