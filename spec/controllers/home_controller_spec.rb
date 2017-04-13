require 'rails_helper'

RSpec.describe HomeController, type: :controller do

  describe "GET #index" do
    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end
    it "renders the :index view" do
      get :index
      expect(response).to render_template :index
    end
    it "populates an array of published projects" do
      p1 = FactoryGirl.create(:default_project)
      p2 = FactoryGirl.create(:published_project)
      get :index
      expect(assigns(:projects)).to eq([p2])
    end
    it "sorts the projects by name" do
      FactoryGirl.create(:published_project, organisation_name: 'b')
      FactoryGirl.create(:published_project, organisation_name: 'a')
      FactoryGirl.create(:published_project, organisation_name: 'c')
      get :index
      expect(assigns(:projects).map { |p| p.organisation_name }).to eq(['a','b','c'])
    end
  end

end
