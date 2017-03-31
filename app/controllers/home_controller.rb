class HomeController < ApplicationController
  def index
  end

  def not_authorized
    render "errors/403"
  end
end
