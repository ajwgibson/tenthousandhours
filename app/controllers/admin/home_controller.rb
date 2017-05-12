class Admin::HomeController < Admin::BaseController

  def index
    @projects_by_organisation_type = Project.group(:organisation_type).count(:all)

    july_3  = Project.could_run_wc_july_3rd(true).count
    july_10 = Project.could_run_wc_july_10th(true).count
    july_17 = Project.could_run_wc_july_17th(true).count
    july_24 = Project.could_run_wc_july_24th(true).count
    @projects_by_requested_week = {
      'July 3rd'  => july_3,
      'July 10th' => july_10,
      'July 17th' => july_17,
      'July 24th' => july_24,
    }

    projects_by_evening = Project.group(:evenings).count(:all)
    @projects_by_evening = {
      'Yes' => projects_by_evening[true]  ||= 0,
      'No'  => projects_by_evening[false] ||= 0,
    }

    projects_by_saturday = Project.group(:saturday).count(:all)
    @projects_by_saturday = {
      'Yes' => projects_by_saturday[true]  ||= 0,
      'No'  => projects_by_saturday[false] ||= 0,
    }

    @projects_cumulative = Project.order(:submitted_at).pluck(:submitted_at).each_with_object(Hash.new(0)) do |s,h|
      h[s.strftime('%d/%m/%Y')] += 1
    end
    total = 0
    @projects_cumulative.each do |key,value|
      total += value
      @projects_cumulative[key] = total
    end

    volunteers = Volunteer.all
    @volunteer_adults = volunteers.inject(0) { |sum,v| sum += v.adults_in_family }
    @volunteer_youth = volunteers.inject(0) { |sum,v| sum += v.youth_in_family }
    @volunteer_children = volunteers.inject(0) { |sum,v| sum += v.children_in_family }

    @commitment = volunteers.inject(0) { |sum,v| sum += v.commitment }

    @personal_project_count           = PersonalProject.count
    @personal_project_volunteer_count = PersonalProject.sum('volunteer_count')
    @personal_project_commitment      = PersonalProject.sum('duration * volunteer_count')

  end


  def not_authorized
    render "errors/403"
  end

end
