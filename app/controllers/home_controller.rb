class HomeController < ApplicationController

  before_action :authenticate_volunteer!, :except => [:index]

  layout :layout

  def index
    @projects = Project.published.order("RANDOM()").limit(3)
    volunteers = Volunteer.all
    @volunteer_count = volunteers.inject(0) {|sum,v| sum += v.family_size }
    project_commitment = volunteers.inject(0) {|sum,v| sum += v.commitment }
    personal_project_commitment = PersonalProject.sum('duration * volunteer_count')
    extra_commitment = ProjectSlot.all.inject(0) { |sum,s| sum += (s.slot_length * s.extra_volunteers) }
    @commitment = (project_commitment + personal_project_commitment + extra_commitment).floor
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
