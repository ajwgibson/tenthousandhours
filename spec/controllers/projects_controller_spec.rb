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
      get :index, params: { with_project_name: 'a' }
      expect(session[:filter_projects]).to eq({'with_project_name' => 'a'})
    end
    it "removes blank filter values" do
      get :index, params: { with_project_name: nil }
      expect(assigns(:filter)).to eq({})
    end
    it "populates a total_project_count value" do
      project_a = FactoryBot.create(:published_project)
      project_b = FactoryBot.create(:default_project)
      get :index
      expect(assigns(:total_project_count)).to eq(1)
    end
    context "with no filter at all" do
      project_a = nil
      project_b = nil

      before do
        project_a = FactoryBot.create(:published_project)
        project_b = FactoryBot.create(:default_project)
      end

      before(:each) do
        get :index
      end

      it "sets 'filtered' to false" do
        expect(assigns(:filtered)).to eq(false)
      end
      it "populates an array of published projects" do
        expect(assigns(:projects)).to eq([project_a])
      end
      it "populates an array of slots" do
        expect(assigns(:slots)).to eq(project_a.project_slots)
      end
      it "populates project_count" do
        expect(assigns(:project_count)).to eq(1)
      end
    end

    context "with filter in the session" do
      it "retrieves and uses filters from the session if none have been supplied" do
        project_a = FactoryBot.create(:published_project, project_name: 'a')
        project_b = FactoryBot.create(:published_project, project_name: 'b')
        slot_a = FactoryBot.create(:default_project_slot, project: project_a)
        slot_b = FactoryBot.create(:default_project_slot, project: project_b)
        get :index, session: { :filter_projects => {'with_project_name' => 'a'} }
        expect(assigns(:projects)).to eq([project_a])
      end
    end

    context "with filter params" do
      it "sets 'filtered' to true" do
        get :index, params: { with_project_name: 'a' }
        expect(assigns(:filtered)).to eq(true)
      end
      it "applies the 'with_project_name' filter" do
        project_a = FactoryBot.create(:published_project, project_name: 'aaa')
        project_b = FactoryBot.create(:published_project, project_name: 'bbb')
        get :index, params: { with_project_name: 'a' }
        expect(assigns(:projects)).to  eq([project_a])
        expect(assigns(:slots)).to     include(project_a.project_slots[0])
        expect(assigns(:slots)).not_to include(project_b.project_slots[0])
      end
      it "applies the 'for_children' filter" do
        project_a = FactoryBot.create(:published_project, kids: 1, activity_1_under_18: true)
        project_b = FactoryBot.create(:published_project, kids: 0, activity_1_under_18: true)
        get :index, params: { for_children: true }
        expect(assigns(:projects)).to eq([project_a])
        expect(assigns(:slots)).to     include(project_a.project_slots[0])
        expect(assigns(:slots)).not_to include(project_b.project_slots[0])
      end
      it "applies the 'for_youth' filter" do
        project_a = FactoryBot.create(:published_project, youth: 1, activity_1_under_18: true)
        project_b = FactoryBot.create(:published_project, youth: 0, activity_1_under_18: true)
        get :index, params: { for_youth: true }
        expect(assigns(:projects)).to eq([project_a])
        expect(assigns(:slots)).to     include(project_a.project_slots[0])
        expect(assigns(:slots)).not_to include(project_b.project_slots[0])
      end
      it "applies the 'for_week' filter" do
        project_a = FactoryBot.create(:published_project)
        project_b = FactoryBot.create(:published_project)
        slot_a = FactoryBot.create(:default_project_slot, project: project_a, slot_date: Date.new(2017,1,1))
        slot_b = FactoryBot.create(:default_project_slot, project: project_b, slot_date: Date.new(2017,1,21))
        get :index, params: { for_week: Date.new(2017,1,1).cweek }
        expect(assigns(:slots)).to eq([slot_a])
        expect(assigns(:projects)).to eq([project_a])
      end
      it "applies the 'for_date' filter" do
        project_a = FactoryBot.create(:default_project, status: :published)
        project_b = FactoryBot.create(:default_project, status: :published)
        slot_a = FactoryBot.create(:default_project_slot, project: project_a, slot_date: Date.new(2017,1,1))
        slot_b = FactoryBot.create(:default_project_slot, project: project_b, slot_date: Date.new(2017,1,21))
        get :index, params: { for_date: Date.new(2017,1,1) }
        expect(assigns(:slots)).to eq([slot_a])
        expect(assigns(:projects)).to eq([project_a])
      end
      it "applies the 'of_type' filter" do
        project_a = FactoryBot.create(:default_project, status: :published)
        project_b = FactoryBot.create(:default_project, status: :published)
        slot_a = FactoryBot.create(:default_project_slot, project: project_a, slot_type: 'evening')
        slot_b = FactoryBot.create(:default_project_slot, project: project_b, slot_type: 'morning')
        get :index, params: { of_type: 'evening' }
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


  describe "GET #show" do

    let(:published_project)   { FactoryBot.create(:published_project) }
    let(:unpublished_project) { FactoryBot.create(:default_project) }

    it "shows a record" do
      get :show, params: { id: published_project.id }
      expect(response).to render_template :show
      expect(response).to have_http_status(:success)
      expect(assigns(:project).id).to eq(published_project.id)
    end

    it "raises an exception for a missing record" do
      assert_raises(ActiveRecord::RecordNotFound) do
        get :show, params: { id: 99 }
      end
    end

    it "raises an exception for a project that isn't published" do
      assert_raises(ActiveRecord::RecordNotFound) do
        get :show, params: { id: unpublished_project.id }
      end
    end

  end

end
