class ProjectsController < ApplicationController

  def index
    @filter = get_filter
    @slots = ProjectSlot.filter(@filter)
    project_ids = @slots.uniq.pluck(:project_id)
    @projects = Project.published.where(id: project_ids).order(:project_name)
    set_filter @filter
  end


  def clear_filter
    set_filter nil
    redirect_to projects_index_url
  end


  def volunteer
    project_slot = ProjectSlot.find params[:slot_id]
    current_volunteer.project_slots << project_slot
    redirect_to projects_index_url, notice: 'Sign up was successful'
  end


  def decline
    project_slot = ProjectSlot.find params[:slot_id]
    current_volunteer.project_slots.delete project_slot
    redirect_to my_projects_url, notice: 'Sign up was removed'
  end


  private

  def get_filter
    filter =
      params.slice(
        :with_project_name,
        :for_children,
        :for_youth,
        :for_week,
        :for_date,
        :of_type,
      )
    filter = session[:filter_projects].symbolize_keys! if filter.empty? && session.key?(:filter_projects)
    filter.delete_if { |key, value| value.blank? }
  end

  def set_filter(filter)
    session[:filter_projects] = filter unless filter.nil?
    session.delete(:filter_projects) if filter.nil?
  end

end
