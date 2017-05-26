class HomeController < ApplicationController

  before_action :authenticate_volunteer!, :except => [:index]

  layout :layout

  def index
    @projects = Project.published.order("RANDOM()").limit(6)
    volunteers = Volunteer.all
    @volunteer_count = volunteers.inject(0) {|sum,v| sum += v.family_size }
    @commitment      = volunteers.inject(0) {|sum,v| sum += v.commitment }
  end


  def my_projects
  end



  private

    def layout
      if action_name == 'index'
        'landing'
      else
        super
      end
    end

end
