require 'rails_helper'

RSpec.describe Admin::ProjectSlotsController, type: :controller do

  login_user

  let(:project) { FactoryBot.create(:default_project) }


  describe "GET #index" do
    it "returns http success" do
      get :index, params: { project_id: project.id }
      expect(response).to have_http_status(:success)
    end
    it "renders the :index view" do
      get :index, params: { project_id: project.id }
      expect(response).to render_template :index
    end
    it "populates the project" do
      get :index, params: { project_id: project.id }
      expect(assigns(:project)).to eq(project)
    end
    it "populates an empty model" do
      get :index, params: { project_id: project.id }
      expect(assigns(:create_project_slot).class).to eq(CreateProjectSlot)
    end
  end


  describe "POST #create" do
    context "with invalid data" do
      def post_create
        attrs = FactoryBot.attributes_for(:create_project_slot, start_date: 'A')
        post :create, params: { project_id: project.id, create_project_slot: attrs }
      end
      it "does not create any new project slots" do
        expect {
          post_create
        }.to_not change(ProjectSlot, :count)
      end
      it "re-renders the form with the posted data and the project" do
        post_create
        expect(response).to render_template(:index)
        expect(assigns(:create_project_slot).start_date).to eq('A')
        expect(assigns(:project)).to eq(project)
      end
    end
    context "with valid data" do
      def post_create
        attrs = FactoryBot.attributes_for(:create_project_slot, start_date: 1.days.from_now.to_s, morning_slot: '1')
        post :create, params: { project_id: project.id, create_project_slot: attrs }
      end
      it "creates a new project slot" do
        expect {
          post_create
        }.to change(ProjectSlot, :count).by(1)
      end
      it "redirects to #index" do
        post_create
        expect(response).to redirect_to :action => :index,
                                        :project_id => project.id
      end
      it "flashes the number of slots created" do
        post_create
        expect(flash[:notice]).to eq('1 slot added')
      end
    end
  end


  describe "DELETE #destroy" do

    let!(:slot) { FactoryBot.create(:default_project_slot) }

    it "soft deletes the record" do
      expect {
        delete :destroy, params: { :id => slot.id }
      }.to change(ProjectSlot, :count).by(-1)
      expect(ProjectSlot.only_deleted.count).to eq(1)
    end

    it "redirects to #index" do
      project_id = slot.project.id
      delete :destroy, params: { :id => slot.id }
      expect(response).to redirect_to :action => :index,
                                      :project_id => project_id
    end

  end


end
