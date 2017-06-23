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


  def new
    @volunteer = Volunteer.new
    render :edit
  end


  def create
    @volunteer = Volunteer.new create_params
    @volunteer.confirmed_at = Time.new
    if @volunteer.save
      redirect_to admin_volunteer_url(@volunteer), notice: 'Volunteer was created successfully'
    else
      render :edit
    end
  end


  def new_sign_up
    @manual_sign_up = ManualSignUp.new
    @projects = Project.published.order(:project_name)
  end


  def create_sign_up
    @manual_sign_up = ManualSignUp.new create_sign_up_params
    if @manual_sign_up.valid?
      slot = ProjectSlot.find @manual_sign_up.slot_id
      slot.volunteers << @volunteer
      redirect_to admin_volunteer_url(@volunteer), notice: 'Project sign up successful'
    else
      @projects = Project.published.order(:project_name)
      render :new_sign_up
    end
  end


  def decline
    project_slot = ProjectSlot.find params[:slot_id]
    @volunteer.project_slots.delete project_slot
    redirect_to admin_volunteer_url(@volunteer), notice: 'Sign up was removed'
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

  def create_params

    # Start with normal whitelisting
    return_values = params
      .require(:volunteer)
      .permit(
        :email,
        :first_name,
        :last_name,
        :mobile,
        :age_category,
        :family,
        :guardian_name,
        :guardian_contact_number,
        :skills => []
      )

    # Add a password
    chars = [('a'..'z'), ('A'..'Z')].map(&:to_a).flatten
    password = (0...10).map { chars[rand(chars.length)] }.join
    return_values[:password] = password
    return_values[:password_confirmation] = password

    # Handle a blank email
    unless return_values.has_key?(:email) && !(return_values[:email].blank?)
      return_values[:email] = "#{SecureRandom.hex(8)}@example.com"
    end

    return_values
  end


  def create_sign_up_params
    params
      .require(:manual_sign_up)
      .permit(
        :slot_id
      )
  end



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
        :without_projects,
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
