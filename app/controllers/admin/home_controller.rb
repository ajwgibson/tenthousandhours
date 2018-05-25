class Admin::HomeController < Admin::BaseController

  def index

    @total_project_count = Project.count

    @projects_by_organisation_type = Project.group(:organisation_type).count(:all)

    week_1 = Project.could_run_week_1(true).count
    week_2 = Project.could_run_week_2(true).count
    week_3 = Project.could_run_week_3(true).count
    week_4 = Project.could_run_week_4(true).count
    @projects_by_requested_week = {
      'Week 1' => week_1,
      'Week 2' => week_2,
      'Week 3' => week_3,
      'Week 4' => week_4,
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

    volunteers = Volunteer.all
    @volunteer_adults = volunteers.inject(0) { |sum,v| sum += v.adults_in_family }
    @volunteer_youth = volunteers.inject(0) { |sum,v| sum += v.youth_in_family }
    @volunteer_children = volunteers.inject(0) { |sum,v| sum += v.children_in_family }

    up_front_commitment = volunteers.inject(0)      { |sum,v| sum += v.commitment }
    extra_commitment    = ProjectSlot.all.inject(0) { |sum,s| sum += (s.slot_length * s.extra_volunteers) }
    @commitment = up_front_commitment + extra_commitment

    @personal_project_count           = PersonalProject.count
    @personal_project_volunteer_count = PersonalProject.sum('volunteer_count')
    @personal_project_commitment      = PersonalProject.sum('duration * volunteer_count')

    @activity_consent_required_count = Volunteer.needs_activity_consent(true).count

  end


  def not_authorized
    render "errors/403"
  end

end
