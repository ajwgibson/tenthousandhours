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
    it "populates no more than 3 published projects" do
      p1 = FactoryGirl.create(:published_project)
      p2 = FactoryGirl.create(:published_project)
      p3 = FactoryGirl.create(:published_project)
      p4 = FactoryGirl.create(:published_project)
      get :index
      expect(assigns(:projects).count).to eq(3)
    end
    it "passes the volunteer count to the view" do
      v1 = FactoryGirl.create(:family_of_four_volunteer)
      v2 = FactoryGirl.create(:family_of_five_volunteer)
      get :index
      expect(assigns(:volunteer_count)).to eq(9)
    end
    it "passes the hours count to the view" do
      slot = FactoryGirl.create(:default_project_slot)
      v1 = FactoryGirl.create(:family_of_four_volunteer)
      v2 = FactoryGirl.create(:family_of_five_volunteer)
      slot.volunteers << v1
      slot.volunteers << v2
      get :index
      expect(assigns(:commitment)).to eq(v1.commitment + v2.commitment)
    end
  end

end
