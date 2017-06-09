class NotificationsController < ActionController::Base

  http_basic_authenticate_with name: Rails.application.config_for(:secrets)["http_basic_auth_username"],
                           password: Rails.application.config_for(:secrets)["http_basic_auth_password"]

  def reminders
    render text: 'Hello world!'
  end

end
