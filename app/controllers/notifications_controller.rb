class NotificationsController < ActionController::Base

  http_basic_authenticate_with name: Rails.application.config_for(:secrets)["http_basic_auth_username"],
                           password: Rails.application.config_for(:secrets)["http_basic_auth_password"]

  def reminders

    already_done = {}
    count = 0

    ProjectSlot.for_date(1.day.from_now).each do |slot|

      already_done[slot.project_id] = [] unless already_done.has_key?(slot.project_id)

      slot.volunteers.each do |v|

        unless already_done[slot.project_id].include? v.id
          message =
            "Hi #{v.first_name}, looking forward to seeing you at " +
            "your 10k hours serve at #{slot.project.project_name} " +
            "at #{slot.start_time} on #{slot.slot_date.strftime('%d/%m/%Y')}"

          TextLocalService.send_message(message, v.mobile_international_format)

          already_done[slot.project_id] << v.id
          count = count + 1
        end

      end
    end

    render text: "#{count} #{'reminder'.pluralize(count)} sent"
  end

end
