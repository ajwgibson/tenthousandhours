require 'kramdown'

module ApplicationHelper

  def is_active_controller(controller_name)
    params[:controller] == controller_name ? "active" : nil
  end


  def is_active_action(action_name)
    params[:action] == action_name ? "active" : nil
  end


  def yes_no_icon(value)
    if value then
      content_tag(:span, " ", class: ["fa", "fa-check", "text-success"])
    else
      content_tag(:span, " ", class: ["fa", "fa-times", "text-danger"])
    end
  end


  def yes_no(value)
    if value then
      content_tag(:span, 'YES ') +
      content_tag(:span, " ", class: ["fa", "fa-check", "text-success"])
    else
      content_tag(:span, 'NO ') +
      content_tag(:span, " ", class: ["fa", "fa-times", "text-danger"])
    end
  end


  def mobile_phone_number(value)
    "+44 (0) #{value.slice(0..3)} #{value.slice(4..value.length)}" unless value.nil?
  end


  def markdown(text)
    Kramdown::Document.new(text ||= '').to_html.html_safe
  end


  def confirmed_label(confirmed)
    content_tag(:small) do
      if confirmed
        content_tag(:span, class: "label label-primary") do
          content_tag(:span, " ", class: ["fa", "fa-check"]) +
          ' CONFIRMED'
        end
      else
        content_tag(:span, class: "label label-danger") do
          content_tag(:span, " ", class: ["fa", "fa-times"]) +
          ' NOT CONFIRMED'
        end
      end
    end
  end


  def sortable(column, filter, path, title=nil)

    title ||= column.titleize

    current_order_by = filter.fetch(:order_by, "")

    is_current = (column == current_order_by.gsub(" desc", ""))
    is_descending = current_order_by.include?("desc")

    filter = filter.except(:order_by)

    filter[:order_by] = column
    filter[:order_by] = (column.split(',').map { |x| x + " desc" }).join(",") if is_current && !is_descending

    css_class = "fa fa-sort-amount"
    css_class += "-asc" if is_current && !is_descending
    css_class += "-desc" if is_current && is_descending

    href = "#{path}?#{filter.to_query}"

    content_tag :a, :href => href  do
      concat("#{title} ")
      concat(content_tag :i, " ", :class => css_class)
    end

  end


  def filter(filter)
    return nil if filter.empty?
    content_tag :dl, class: 'dl-horizontal' do
      filter.each do |key, value|
        concat content_tag :dt, key.to_s.humanize
        concat content_tag :dd, value unless ['true', 'false'].include? value
        concat content_tag :dd, value == 'true' ? 'Yes' : 'No' if ['true', 'false'].include? value
      end
    end
  end


  #
  # Toastr messages used for application flashes
  #

  ALERT_TYPES = [:success, :info, :warning, :error] unless const_defined?(:ALERT_TYPES)

  def toastr_flash(options = {})

    flash_messages = []

    flash.each do |type, message|

      next if message.blank?

      type = type.to_sym
      type = :success if type == :notice
      type = :info    if type == :alert
      type = :error   if type == :error
      next unless ALERT_TYPES.include?(type)

      Array(message).each do |msg|
        text = content_tag(:div, msg, "data-toastr-type" => type, :class => "toastr-message hidden")
        flash_messages << text if msg
      end
    end

    flash_messages.join("\n").html_safe
  end

end
