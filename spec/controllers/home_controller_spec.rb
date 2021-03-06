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
      p1 = FactoryBot.create(:default_project)
      p2 = FactoryBot.create(:published_project)
      get :index
      expect(assigns(:projects)).to eq([p2])
    end
    it "populates no more than 3 published projects" do
      p1 = FactoryBot.create(:published_project)
      p2 = FactoryBot.create(:published_project)
      p3 = FactoryBot.create(:published_project)
      p4 = FactoryBot.create(:published_project)
      get :index
      expect(assigns(:projects).count).to eq(3)
    end
    it "passes the volunteer count to the view" do
      v1 = FactoryBot.create(:family_of_four_volunteer)
      v2 = FactoryBot.create(:family_of_five_volunteer)
      get :index
      expect(assigns(:volunteer_count)).to eq(9)
    end
    it "passes the (rounded down) hours count to the view" do
      project = FactoryBot.create(:default_project,   morning_slot_length: 1.5)
      slot = FactoryBot.create(:default_project_slot, slot_type: :morning, project: project, extra_volunteers: 3)
      v1 = FactoryBot.create(:family_of_four_volunteer)
      v2 = FactoryBot.create(:family_of_five_volunteer)
      pp = FactoryBot.create(:default_personal_project, duration: 1.1, volunteer_count: 3)
      slot.volunteers << v1
      slot.volunteers << v2
      get :index
      # commitment = ((4*1.5) + (5*1.5) + (3*1.5) + (3*1.1)).floor = 21
      expect(assigns(:commitment)).to eq(21)
    end
  end

end
