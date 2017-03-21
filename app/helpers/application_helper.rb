module ApplicationHelper

  def is_active_controller(controller_name)
    params[:controller] == controller_name ? "active" : nil
  end


  def is_active_action(action_name)
    params[:action] == action_name ? "active" : nil
  end

  #
  # Toastr messages used for application flashes
  #

  ALERT_TYPES = [:success, :info, :warning, :danger] unless const_defined?(:ALERT_TYPES)

  def toastr_flash(options = {})

    flash_messages = []

    flash.each do |type, message|

      next if message.blank?

      type = type.to_sym
      type = :success if type == :notice
      type = :info    if type == :alert
      type = :danger  if type == :error
      next unless ALERT_TYPES.include?(type)

      Array(message).each do |msg|
        text = content_tag(:div, msg, "data-toastr-type" => type, :class => "toastr-message hidden")
        flash_messages << text if msg
      end
    end

    flash_messages.join("\n").html_safe
  end
  
end
