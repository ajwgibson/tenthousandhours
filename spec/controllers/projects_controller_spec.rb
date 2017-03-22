require 'rails_helper'

RSpec.describe ProjectsController, type: :controller do

  describe "GET #index" do
    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end
    it "renders the :index view" do
      get :index
      expect(response).to render_template :index
    end
    it "populates an array of projects" do
      project = FactoryGirl.create(:default_project)
      get :index
      expect(assigns(:projects)).to eq([project])
    end
  end


  describe "GET #import" do
    it "renders a file_upload form" do
      get :import
      expect(assigns(:file_upload).filename).to be_nil
    end
  end

end
