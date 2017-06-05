class Admin::TextMessagesController < Admin::BaseController

  load_and_authorize_resource


  def index
    @filter = get_filter
    @messages = TextMessage.filter(@filter).order(created_at: :desc)
    @messages = @messages.page params[:page]
    set_filter @filter
  end


  def clear_filter
    set_filter nil
    redirect_to admin_text_messages_url
  end


  def show
  end


private

  def get_filter
    filter =
      params.slice(
        :with_recipient,
        :order_by,
      )
    filter = session[:filter_admin_text_messages].symbolize_keys! if filter.empty? && session.key?(:filter_admin_text_messages)
    filter = { :order_by => 'created_at desc' } if filter.empty?
    filter.delete_if { |key, value| value.blank? }
  end


  def set_filter(filter)
    session[:filter_admin_text_messages] = filter unless filter.nil?
    session.delete(:filter_admin_text_messages) if filter.nil?
  end

end
