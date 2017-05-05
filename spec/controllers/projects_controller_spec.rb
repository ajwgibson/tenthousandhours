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
    it "stores filters to the session" do
      get :index, with_project_name: 'a'
      expect(session[:filter_projects]).to eq({'with_project_name' => 'a'})
    end
    it "removes blank filter values" do
      get :index, with_project_name: nil
      expect(assigns(:filter)).to eq({})
    end
    context "with no filter at all" do
      it "populates an array of published projects and an array of all slots" do
        project_a = FactoryGirl.create(:published_project)
        project_b = FactoryGirl.create(:default_project)
        get :index
        expect(assigns(:projects)).to eq([project_a])
        expect(assigns(:slots)).to eq(project_a.project_slots)
      end
    end
    context "with filter in the session" do
      it "retrieves and uses filters from the session if none have been supplied" do
        project_a = FactoryGirl.create(:published_project, project_name: 'a')
        project_b = FactoryGirl.create(:published_project, project_name: 'b')
        slot_a = FactoryGirl.create(:default_project_slot, project: project_a)
        slot_b = FactoryGirl.create(:default_project_slot, project: project_b)
        get :index, { }, { :filter_projects => {'with_project_name' => 'a'} }
        expect(assigns(:projects)).to eq([project_a])
      end
    end
    context "with filter params" do
      it "applies the 'with_project_name' filter" do
        project_a = FactoryGirl.create(:published_project, project_name: 'aaa')
        project_b = FactoryGirl.create(:published_project, project_name: 'bbb')
        get :index, with_project_name: 'a'
        expect(assigns(:projects)).to  eq([project_a])
        expect(assigns(:slots)).to     include(project_a.project_slots[0])
        expect(assigns(:slots)).not_to include(project_b.project_slots[0])
      end
      it "applies the 'for_children' filter" do
        project_a = FactoryGirl.create(:published_project, kids: 1, activity_1_under_18: true)
        project_b = FactoryGirl.create(:published_project, kids: 0, activity_1_under_18: true)
        get :index, for_children: true
        expect(assigns(:projects)).to eq([project_a])
        expect(assigns(:slots)).to     include(project_a.project_slots[0])
        expect(assigns(:slots)).not_to include(project_b.project_slots[0])
      end
      it "applies the 'for_youth' filter" do
        project_a = FactoryGirl.create(:published_project, youth: 1, activity_1_under_18: true)
        project_b = FactoryGirl.create(:published_project, youth: 0, activity_1_under_18: true)
        get :index, for_youth: true
        expect(assigns(:projects)).to eq([project_a])
        expect(assigns(:slots)).to     include(project_a.project_slots[0])
        expect(assigns(:slots)).not_to include(project_b.project_slots[0])
      end
      it "applies the 'for_week' filter" do
        project_a = FactoryGirl.create(:published_project)
        project_b = FactoryGirl.create(:published_project)
        slot_a = FactoryGirl.create(:default_project_slot, project: project_a, slot_date: Date.new(2017,7,1))
        slot_b = FactoryGirl.create(:default_project_slot, project: project_b, slot_date: Date.new(2017,7,21))
        get :index, for_week: Date.new(2017,7,1).cweek
        expect(assigns(:slots)).to eq([slot_a])
        expect(assigns(:projects)).to eq([project_a])
      end
      it "applies the 'for_date' filter" do
        project_a = FactoryGirl.create(:default_project, status: :published)
        project_b = FactoryGirl.create(:default_project, status: :published)
        slot_a = FactoryGirl.create(:default_project_slot, project: project_a, slot_date: Date.new(2017,7,1))
        slot_b = FactoryGirl.create(:default_project_slot, project: project_b, slot_date: Date.new(2017,7,21))
        get :index, for_date: Date.new(2017,7,1)
        expect(assigns(:slots)).to eq([slot_a])
        expect(assigns(:projects)).to eq([project_a])
      end
      it "applies the 'of_type' filter" do
        project_a = FactoryGirl.create(:default_project, status: :published)
        project_b = FactoryGirl.create(:default_project, status: :published)
        slot_a = FactoryGirl.create(:default_project_slot, project: project_a, slot_type: 'evening')
        slot_b = FactoryGirl.create(:default_project_slot, project: project_b, slot_type: 'morning')
        get :index, of_type: 'evening'
        expect(assigns(:slots)).to eq([slot_a])
        expect(assigns(:projects)).to eq([project_a])
      end

    end
  end


  describe "GET #clear_filter" do
    it "redirects to #index" do
      get :clear_filter
      expect(response).to redirect_to(projects_index_url)
    end
    it "clears the session entry" do
      session[:filter_projects] = {'for_youth' => true}
      get :clear_filter
      expect(session.key?(:filter_projects)).to be false
    end
  end

end
