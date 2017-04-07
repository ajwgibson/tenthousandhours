require 'rails_helper'

RSpec.describe ProjectsController, type: :controller do

  login_user

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


  describe "GET #show" do

    let(:project) { FactoryGirl.create(:default_project) }

    it "shows a record" do
      get :show, { id: project.id }
      expect(response).to render_template :show
      expect(response).to have_http_status(:success)
      expect(assigns(:project).id).to eq(project.id)
    end

    it "raises an exception for a missing record" do
      assert_raises(ActiveRecord::RecordNotFound) do
        get :show, { id: 99 }
      end
    end

  end


  describe "GET #new" do
    it "renders a blank form" do
      get :new
      expect(response).to render_template :edit
      expect(response).to have_http_status(:success)
      expect(assigns(:project).id).to be_nil
    end
  end


  describe "POST #create" do

    context "with valid data" do

      let(:project) { Project.first }

      def post_create
        attrs = {
          typeform_id:           '12345',
          organisation_type:     'School',
          organisation_name:     'A school',
          contact_name:          'Joe Bloggs',
          contact_role:          'Teacher',
          contact_email:         'joe.bloggs@a-school.com',
          contact_phone:         '02870341234',
          project_1_summary:     'The first project',
          project_1_information: 'More info about the first project',
          project_1_under_18:    true,
          project_2_summary:     'The second project',
          project_2_information: 'More info about the second project',
          project_2_under_18:    false,
          project_3_summary:     'The third project',
          project_3_information: 'More info about the third project',
          project_3_under_18:    true,
          any_week:              false,
          july_3:                true,
          july_10:               false,
          july_17:               true,
          july_24:               false,
          evenings:              true,
          saturday:              false,
          notes:                 'More notes about the project',
          submitted_at:          1.days.ago.change(:sec => 0),
          adults:                10,
          youth:                 20,
          materials:             'Paints and brushes',
        }
        post :create, { project: attrs }
      end

      before(:each) do
        post_create
      end

      it "creates a new record" do
        expect {
          post_create
        }.to change(Project, :count).by(1)
      end

      it "redirects to the index action" do
        expect(response).to redirect_to(projects_path())
      end

      it "set a flash message" do
        expect(flash[:notice]).to eq('Project was created successfully')
      end

      it "does not store the typeform_id" do expect(project.typeform_id).to be_nil end
      it "does not use the supplied submitted_at" do expect(project.submitted_at.to_date).to eq(Date.today.to_date) end

      it "stores organisation_type" do expect(project.organisation_type).to eq('School') end
      it "stores organisation_name" do expect(project.organisation_name).to eq('A school') end
      it "stores contact_name" do expect(project.contact_name).to eq('Joe Bloggs') end
      it "stores contact_role" do expect(project.contact_role).to eq('Teacher') end
      it "stores contact_email" do expect(project.contact_email).to eq('joe.bloggs@a-school.com') end
      it "stores contact_phone" do expect(project.contact_phone).to eq('02870341234') end
      it "stores project_1_summary" do expect(project.project_1_summary).to eq('The first project') end
      it "stores project_1_information" do expect(project.project_1_information).to eq('More info about the first project') end
      it "stores project_1_under_18" do expect(project.project_1_under_18).to be_truthy end
      it "stores project_2_summary" do expect(project.project_2_summary).to eq('The second project') end
      it "stores project_2_information" do expect(project.project_2_information).to eq('More info about the second project') end
      it "stores project_2_under_18" do expect(project.project_2_under_18).to be_falsey end
      it "stores project_3_summary" do expect(project.project_3_summary).to eq('The third project') end
      it "stores project_3_information" do expect(project.project_3_information).to eq('More info about the third project') end
      it "stores project_3_under_18" do expect(project.project_3_under_18).to be_truthy end
      it "stores any_week" do expect(project.any_week).to be_falsey end
      it "stores july_3" do expect(project.july_3).to be_truthy end
      it "stores july_10" do expect(project.july_10).to be_falsey end
      it "stores july_17" do expect(project.july_17).to be_truthy end
      it "stores july_24" do expect(project.july_24).to be_falsey end
      it "stores evenings" do expect(project.evenings).to be_truthy end
      it "stores saturday" do expect(project.saturday).to be_falsey end
      it "stores notes" do expect(project.notes).to eq('More notes about the project') end
      it "stores adults" do expect(project.adults).to eq(10) end
      it "stores youth" do expect(project.youth).to eq(20) end
      it "stores materials" do expect(project.materials).to eq('Paints and brushes') end
    end

    context "with invalid data" do
      def post_create
        attrs = FactoryGirl.attributes_for(:project, :organisation_name => 'A')
        post :create, { project: attrs }
      end
      it "does not create a new record" do
        expect {
          post_create
        }.to_not change(Project, :count)
      end
      it "re-renders the form with the posted data" do
        post_create
        expect(response).to render_template(:edit)
        expect(assigns(:project).organisation_name).to eq('A')
      end
    end
  end


  describe "GET #edit" do

    let(:project) { FactoryGirl.create(:default_project) }

    it "shows a record for editing" do
      get :edit, { id: project.id }
      expect(response).to render_template :edit
      expect(response).to have_http_status(:success)
      expect(assigns(:project).id).to eq(project.id)
    end

    it "raises an exception for a missing record" do
      assert_raises(ActiveRecord::RecordNotFound) do
        get :edit, { id: 99 }
      end
    end

  end


  describe "PUT #update" do

    context "with valid data" do

      let(:project) { FactoryGirl.create(:default_project, :organisation_name => 'Original') }

      def post_update
        put :update, :id => project.id, :project => { :organisation_name => 'Changed' }
        project.reload
      end

      before(:each) do
        post_update
      end

      it "updates the project details" do
        expect(project.organisation_name).to eq('Changed')
      end

      it "redirects to the show action" do
        expect(response).to redirect_to(project_path(assigns(:project)))
      end

      it "set a flash message" do
        expect(flash[:notice]).to eq('Project was updated successfully')
      end

    end

    context "with invalid data" do

      let(:project) { FactoryGirl.create(:default_project, :organisation_name => 'Original') }

      def post_update
        put :update, :id => project.id, :project => { :organisation_name => nil }
        project.reload
      end

      before(:each) do
        post_update
      end

      it "does not update the project details" do
        expect(project.organisation_name).to eq('Original')
      end

      it "re-renders the form with the posted data" do
        expect(response).to render_template(:edit)
        expect(assigns(:project).organisation_name).to be_nil
      end

    end

  end


  describe "DELETE #destroy" do

    let!(:project) { FactoryGirl.create(:default_project) }

    it "soft deletes the record" do
      expect {
        delete :destroy, :id => project.id
      }.to change(Project, :count).by(-1)
      expect(Project.only_deleted.count).to eq(1)
    end

    it "redirects to #index" do
      delete :destroy, :id => project.id
      expect(response).to redirect_to(:projects)
    end

  end


  describe "GET #review" do

    let(:project) { FactoryGirl.create(:default_project) }

    it "shows a record for editing" do
      get :review, { id: project.id }
      expect(response).to render_template :review
      expect(response).to have_http_status(:success)
      expect(assigns(:project).id).to eq(project.id)
    end
    it "raises an exception for a missing record" do
      assert_raises(ActiveRecord::RecordNotFound) do
        get :review, { id: 99 }
      end
    end
  end


  describe "PUT #do_review" do
    context "with valid data" do

      let(:project) { FactoryGirl.create(:default_project) }

      def post_update
        put :do_review, :id => project.id, :project => {
          adults:                4,
          youth:                 2,
          materials:             'Stuff',
          project_1_summary:     'The first project',
          project_1_information: 'More info about the first project',
          project_1_under_18:    true,
          project_2_summary:     'The second project',
          project_2_information: 'More info about the second project',
          project_2_under_18:    true,
          project_3_summary:     'The third project',
          project_3_information: 'More info about the third project',
          project_3_under_18:    true,
        }
        project.reload
      end

      before(:each) do
        post_update
      end

      it "updates adults"                do expect(project.adults).to                eq(4) end
      it "updates youth"                 do expect(project.youth).to                 eq(2) end
      it "updates materials"             do expect(project.materials).to             eq('Stuff') end
      it "updates project_1_summary"     do expect(project.project_1_summary).to     eq('The first project') end
      it "updates project_1_information" do expect(project.project_1_information).to eq('More info about the first project') end
      it "updates project_1_under_18"    do expect(project.project_1_under_18).to    be_truthy end
      it "updates project_2_summary"     do expect(project.project_2_summary).to     eq('The second project') end
      it "updates project_2_information" do expect(project.project_2_information).to eq('More info about the second project') end
      it "updates project_2_under_18"    do expect(project.project_2_under_18).to    be_truthy end
      it "updates project_3_summary"     do expect(project.project_3_summary).to     eq('The third project') end
      it "updates project_3_information" do expect(project.project_3_information).to eq('More info about the third project') end
      it "updates project_3_under_18"    do expect(project.project_3_under_18).to    be_truthy end

      it "redirects to the show action" do
        expect(response).to redirect_to(project_path(assigns(:project)))
      end
      it "set a flash message" do
        expect(flash[:notice]).to eq('Project was updated successfully')
      end
    end

    context "with invalid data" do

      let(:project) { FactoryGirl.create(:default_project, :adults => 10) }

      def post_update
        put :do_review, :id => project.id, :project => { :adults => 0 }
        project.reload
      end

      before(:each) do
        post_update
      end

      it "does not update the project details" do
        expect(project.adults).to eq(10)
      end
      it "re-renders the form with the posted data" do
        expect(response).to render_template(:review)
        expect(assigns(:project).adults).to eq(0)
      end
    end
  end


  describe "GET #summary" do

    let(:project) { FactoryGirl.create(:default_project) }

    it "shows a record for editing" do
      get :summary, { id: project.id }
      expect(response).to render_template :summary
      expect(response).to have_http_status(:success)
      expect(assigns(:project).id).to eq(project.id)
    end
    it "raises an exception for a missing record" do
      assert_raises(ActiveRecord::RecordNotFound) do
        get :summary, { id: 99 }
      end
    end

  end


  describe "PUT #do_summary" do

    let(:project) { FactoryGirl.create(:default_project) }

    def post_update
      put :do_summary, :id => project.id, :project => {
        summary: 'Some summary text'
      }
      project.reload
    end

    before(:each) do
      post_update
    end

    it "updates summary" do
      expect(project.summary).to eq('Some summary text')
    end

    it "redirects to the show action" do
      expect(response).to redirect_to(project_path(assigns(:project)))
    end

    it "set a flash message" do
      expect(flash[:notice]).to eq('Project summary was updated successfully')
    end

  end

end
