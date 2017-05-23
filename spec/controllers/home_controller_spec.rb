require 'rails_helper'

RSpec.describe HomeController, type: :controller do

  login_volunteer


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
    it "populates no more than 6 published projects" do
      p1 = FactoryGirl.create(:published_project)
      p2 = FactoryGirl.create(:published_project)
      p3 = FactoryGirl.create(:published_project)
      p4 = FactoryGirl.create(:published_project)
      p5 = FactoryGirl.create(:published_project)
      p6 = FactoryGirl.create(:published_project)
      p7 = FactoryGirl.create(:published_project)
      get :index
      expect(assigns(:projects).count).to eq(6)
    end
  end

end
