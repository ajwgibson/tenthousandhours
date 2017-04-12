class Admin::HomeController < Admin::BaseController
  def not_authorized
    render "errors/403"
  end
end
