class Admin::VolunteersController < Admin::BaseController

  load_and_authorize_resource


  def index
    @volunteers = Volunteer.all
  end

  def show
  end

end
