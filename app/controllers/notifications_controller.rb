class NotificationsController < ActionController::Base

  http_basic_authenticate_with name: Rails.application.config_for(:secrets)["http_basic_auth_username"],
                           password: Rails.application.config_for(:secrets)["http_basic_auth_password"]

  def reminders

    count = 0

    ProjectSlot.for_date(1.day.from_now).each do |slot|
      slot.volunteers.each do |volunteer|
        unless (volunteer.reminders.where(project: slot.project).where(reminder_date: slot.slot_date).exists?)
          message =
            "Hi #{volunteer.first_name}, looking forward to seeing you at " +
            "your 10k hours serve at #{slot.project.project_name} " +
            "at #{slot.start_time} on #{slot.slot_date.strftime('%d/%m/%Y')}"

          TextLocalService.send_message(message, volunteer.mobile_international_format)

          count = count + 1

          reminder = Reminder.new
          reminder.project       = slot.project
          reminder.volunteer     = volunteer
          reminder.reminder_date = slot.slot_date
          reminder.save
        end
      end
    end

    render text: "#{count} #{'reminder'.pluralize(count)} sent"
  end

end
