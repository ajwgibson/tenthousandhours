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


  def project_start_times(project)
    return nil unless project.needs_morning_start_time? || project.needs_afternoon_start_time? || project.needs_evening_start_time?
    content_tag(:p) do
      if project.needs_morning_start_time?
        concat "Morning start time: #{project.morning_start_time ||= 'tbc'}"
        concat " (#{project.morning_slot_length} hrs)" unless project.morning_slot_length.nil?
        concat tag(:br)
      end
      if project.needs_afternoon_start_time?
        concat "Afternoon start time: #{project.afternoon_start_time ||= 'tbc'}"
        concat " (#{project.afternoon_slot_length} hrs)" unless project.afternoon_slot_length.nil?
        concat tag(:br)
      end
      if project.needs_evening_start_time?
        concat "Evening start time: #{project.evening_start_time ||= 'tbc'}"
        concat " (#{project.evening_slot_length} hrs)" unless project.evening_slot_length.nil?
        concat tag(:br)
      end
    end
  end

end
