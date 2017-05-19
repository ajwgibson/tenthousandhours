class Admin::TextMessagesController < Admin::BaseController

  load_and_authorize_resource


  def index
    @messages = TextMessage.order(created_at: :desc).all
  end

  def show
  end

end
