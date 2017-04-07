module ProjectsHelper

  def styled_project_dates(project)
    return nil if project.start_date.nil?
    format = "#{project.start_date.day.ordinalize} %B"
    format = "#{project.start_date.day.ordinalize} to #{project.end_date.day.ordinalize} %B" unless project.start_date == project.end_date
    content_tag(:strong) do
      content_tag(:em) do
        project_dates project
      end
    end
  end

  def project_dates(project)
    return nil if project.start_date.nil?
    format = "#{project.start_date.day.ordinalize} %B"
    format = "#{project.start_date.day.ordinalize} to #{project.end_date.day.ordinalize} %B" unless project.start_date == project.end_date
    project.start_date.strftime(format)
  end

end
