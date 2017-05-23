class HomeController < ApplicationController

  before_action :authenticate_volunteer!, :except => [:index]

  layout :layout

  def index
    @projects = Project.published.order("RANDOM()").limit(6)
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
