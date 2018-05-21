require 'rails_helper'

RSpec.describe PersonalProjectsController, type: :controller do

  login_volunteer


  describe "GET #new" do
    it "renders a blank form" do
      get :new
      expect(response).to render_template :new
      expect(response).to have_http_status(:success)
      expect(assigns(:personal_project).id).to be_nil
    end
  end


  describe "POST #create" do
    context "with invalid data" do
      def post_create
        attrs = FactoryBot.attributes_for(:personal_project, description: 'Something')
        post :create, params: { personal_project: attrs }
      end
      it "does not create a new record" do
        expect {
          post_create
        }.to_not change(PersonalProject, :count)
      end
      it "re-renders the form with the posted data" do
        post_create
        expect(response).to render_template(:new)
        expect(assigns(:personal_project).description).to eq('Something')
      end
    end
    context "with valid data" do
      let(:personal_project) { PersonalProject.first }
      def post_create
        attrs =
          FactoryBot.attributes_for(
            :personal_project,
            project_date: '2017-07-12',
            volunteer_count: 3,
            duration: 2.5,
            description: 'Some details')
        post :create, params: { personal_project: attrs }
      end
      before(:each) do
        post_create
      end
      it "creates a new record" do
        expect {
          post_create
        }.to change(PersonalProject, :count).by(1)
      end
      it "links the new record to the logged in volunteer" do
        expect(personal_project.volunteer).to eq(Volunteer.first)
      end
      it "redirects to the my projects page" do
        expect(response).to redirect_to(my_projects_path())
      end
      it "set a flash message" do
        expect(flash[:notice]).to eq('Personal project was created successfully')
      end
      it "stores project_date" do expect(personal_project.project_date).to eq(Date.new(2017,7,12)) end
      it "stores volunteer_count" do expect(personal_project.volunteer_count).to eq(3) end
      it "stores duration" do expect(personal_project.duration).to eq(2.5) end
      it "stores description" do expect(personal_project.description).to eq('Some details') end
    end
  end


  describe "GET #edit" do
    let(:project) { FactoryBot.create(:default_personal_project) }
    it "shows a record for editing" do
      get :edit, params: { id: project.id }
      expect(response).to render_template :new
      expect(response).to have_http_status(:success)
      expect(assigns(:personal_project).id).to eq(project.id)
    end
    it "raises an exception for a missing record" do
      assert_raises(ActiveRecord::RecordNotFound) do
        get :edit, params: { id: 99 }
      end
    end
  end


  describe "PUT #update" do
    context "with valid data" do
      let(:project) { FactoryBot.create(:default_personal_project, :description => 'Original') }
      def post_update
        put :update, params: { id: project.id, personal_project: { description: 'Changed' } }
        project.reload
      end
      before(:each) do
        post_update
      end
      it "updates the personal project details" do
        expect(project.description).to eq('Changed')
      end
      it "redirects to the my_projects page" do
        expect(response).to redirect_to(my_projects_url)
      end
      it "set a flash message" do
        expect(flash[:notice]).to eq('Project was updated successfully')
      end
    end
    context "with invalid data" do
      let(:project) { FactoryBot.create(:default_personal_project, description: 'Original') }
      def post_update
        put :update, params: { id: project.id, personal_project: { description: nil } }
        project.reload
      end
      before(:each) do
        post_update
      end
      it "does not update the personal project details" do
        expect(project.description).to eq('Original')
      end
      it "re-renders the form with the posted data" do
        expect(response).to render_template(:new)
        expect(assigns(:personal_project).description).to be_empty
      end
    end
  end


  describe "DELETE #destroy" do
    let!(:project) { FactoryBot.create(:default_personal_project) }
    it "soft deletes the record" do
      expect {
        delete :destroy, params: { id: project.id }
      }.to change(PersonalProject, :count).by(-1)
      expect(PersonalProject.only_deleted.count).to eq(1)
    end
    it "redirects to my_projects" do
      delete :destroy, params: { id: project.id }
      expect(response).to redirect_to(my_projects_url)
    end
  end


end
