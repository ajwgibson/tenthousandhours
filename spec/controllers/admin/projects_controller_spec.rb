require 'rails_helper'

RSpec.describe Admin::ProjectsController, type: :controller do

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
      project = FactoryBot.create(:default_project)
      get :index
      expect(assigns(:projects)).to eq([project])
    end
    it "orders projects by project_name by default" do
      b = FactoryBot.create(:default_project, project_name: 'b')
      c = FactoryBot.create(:default_project, project_name: 'c')
      a = FactoryBot.create(:default_project, project_name: 'a')
      get :index
      expect(assigns(:projects)).to eq([a,b,c])
    end
    it "applies the 'order_by' parameter" do
      b = FactoryBot.create(:default_project, project_name: 'b')
      c = FactoryBot.create(:default_project, project_name: 'c')
      a = FactoryBot.create(:default_project, project_name: 'a')
      get :index, params: {order_by: 'project_name desc' }
      expect(assigns(:projects)).to eq([c,b,a])
    end
    it "applies the 'could_run_week_1' filter" do
      a = FactoryBot.create(:default_project, :week_1 => true , any_week: false)
      b = FactoryBot.create(:default_project, :week_1 => false, any_week: false)
      get :index, params: {could_run_week_1: true }
      expect(assigns(:projects)).to eq([a])
    end
    it "applies the 'could_run_week_2' filter" do
      a = FactoryBot.create(:default_project, :week_2 => true , any_week: false)
      b = FactoryBot.create(:default_project, :week_2 => false, any_week: false)
      get :index, params: {could_run_week_2: true }
      expect(assigns(:projects)).to eq([a])
    end
    it "applies the 'could_run_week_3' filter" do
      a = FactoryBot.create(:default_project, :week_3 => true , any_week: false)
      b = FactoryBot.create(:default_project, :week_3 => false, any_week: false)
      get :index, params: {could_run_week_3: true }
      expect(assigns(:projects)).to eq([a])
    end
    it "applies the 'could_run_week_4' filter" do
      a = FactoryBot.create(:default_project, :week_4 => true , any_week: false)
      b = FactoryBot.create(:default_project, :week_4 => false, any_week: false)
      get :index, params: {could_run_week_4: true }
      expect(assigns(:projects)).to eq([a])
    end
    it "applies the 'could_run_evenings' filter" do
      a = FactoryBot.create(:default_project, evenings: true)
      b = FactoryBot.create(:default_project, evenings: false)
      get :index, params: {could_run_evenings: true }
      expect(assigns(:projects)).to eq([a])
    end
    it "applies the 'could_run_saturday' filter" do
      a = FactoryBot.create(:default_project, saturday: true)
      b = FactoryBot.create(:default_project, saturday: false)
      get :index, params: {could_run_saturday: true }
      expect(assigns(:projects)).to eq([a])
    end
    it "applies the 'with_name' filter" do
      a = FactoryBot.create(:default_project, project_name: 'a')
      b = FactoryBot.create(:default_project, project_name: 'b')
      get :index, params: {with_name: 'a' }
      expect(assigns(:projects)).to eq([a])
    end
    it "applies the 'of_type' filter" do
      a = FactoryBot.create(:default_project, organisation_type: 'a')
      b = FactoryBot.create(:default_project, organisation_type: 'b')
      get :index, params: {of_type: 'a' }
      expect(assigns(:projects)).to eq([a])
    end
    it "applies the 'with_status' filter" do
      a = FactoryBot.create(:default_project, status: :draft)
      b = FactoryBot.create(:default_project, status: :published)
      get :index, params: {with_status: Project.statuses[:draft] }
      expect(assigns(:projects)).to eq([a])
    end
    it "stores filters to the session" do
      get :index, params: {could_run_week_1: true }
      expect(session[:filter_admin_projects]).to eq({'could_run_week_1' => 'true'})
    end
    it "removes blank filter values" do
      get :index, params: {could_run_week_1: nil }
      expect(assigns(:filter)).to eq({})
    end
    it "retrieves filters from the session if none have been supplied" do
      a = FactoryBot.create(:default_project, :week_1 => true , any_week: false)
      b = FactoryBot.create(:default_project, :week_1 => false, any_week: false)
      get :index, session: { :filter_admin_projects => {'could_run_week_1' => 'true'} }
      expect(assigns(:projects)).to eq([a])
    end
  end


  describe "GET #clear_filter" do
    it "redirects to #index" do
      get :clear_filter
      expect(response).to redirect_to([:admin, :projects])
    end
    it "clears the session entry" do
      session[:filter_admin_projects] = {'could_run_week_1' => true}
      get :clear_filter
      expect(session.key?(:filter_admin_projects)).to be false
    end
  end


  describe "GET #print_list" do
    it "returns http success" do
      get :print_list
      expect(response).to have_http_status(:success)
    end
    it "renders the :print_list view" do
      get :print_list
      expect(response).to render_template :print_list
    end
    it "populates an array of projects using the current filter settings" do
      a = FactoryBot.create(:default_project, organisation_type: 'a', project_name: 'a')
      b = FactoryBot.create(:default_project, organisation_type: 'b', project_name: 'b')
      c = FactoryBot.create(:default_project, organisation_type: 'a', project_name: 'c')
      get :print_list, session: { filter_admin_projects: { 'of_type' => 'a', 'order_by' => 'project_name desc' } }
      expect(assigns(:projects).map { |p| p.project_name }).to eq(['c','a'])
    end
  end


  describe "GET #import" do
    it "renders a file_upload form" do
      get :import
      expect(assigns(:file_upload).filename).to be_nil
    end
  end


  describe "GET #show" do

    let(:project) { FactoryBot.create(:default_project) }

    it "shows a record" do
      get :show, params: { id: project.id }
      expect(response).to render_template :show
      expect(response).to have_http_status(:success)
      expect(assigns(:project).id).to eq(project.id)
    end

    it "raises an exception for a missing record" do
      assert_raises(ActiveRecord::RecordNotFound) do
        get :show, params: { id: 99 }
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
          project_name:     'A school',
          contact_name:          'Joe Bloggs',
          contact_role:          'Teacher',
          contact_email:         'joe.bloggs@a-school.com',
          contact_phone:         '02870341234',
          activity_1_summary:     'The first project',
          activity_1_information: 'More info about the first project',
          activity_1_under_18:    true,
          activity_2_summary:     'The second project',
          activity_2_information: 'More info about the second project',
          activity_2_under_18:    false,
          activity_3_summary:     'The third project',
          activity_3_information: 'More info about the third project',
          activity_3_under_18:    true,
          any_week:              false,
          week_1:                true,
          week_2:               false,
          week_3:               true,
          week_4:               false,
          evenings:              true,
          saturday:              false,
          notes:                 'More notes about the project',
          submitted_at:          1.days.ago.change(:sec => 0),
          adults:                10,
          youth:                 20,
          kids:                  30,
          materials:             'Paints and brushes',
          leader:                'Joe Bloggs',
          morning_start_time:    '09:30',
          afternoon_start_time:  '14:45',
          evening_start_time:    '19:15',
          morning_slot_length:   1.5,
          afternoon_slot_length: 2.5,
          evening_slot_length:   3.5,
        }
        post :create, params: { project: attrs }
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
        expect(response).to redirect_to(admin_projects_path())
      end

      it "set a flash message" do
        expect(flash[:notice]).to eq('Project was created successfully')
      end

      it "does not store the typeform_id" do expect(project.typeform_id).to be_nil end
      it "does not use the supplied submitted_at" do expect(project.submitted_at.to_date).to eq(Date.today.to_date) end

      it "stores organisation_type" do expect(project.organisation_type).to eq('School') end
      it "stores project_name" do expect(project.project_name).to eq('A school') end
      it "stores contact_name" do expect(project.contact_name).to eq('Joe Bloggs') end
      it "stores contact_role" do expect(project.contact_role).to eq('Teacher') end
      it "stores contact_email" do expect(project.contact_email).to eq('joe.bloggs@a-school.com') end
      it "stores contact_phone" do expect(project.contact_phone).to eq('02870341234') end
      it "stores activity_1_summary" do expect(project.activity_1_summary).to eq('The first project') end
      it "stores activity_1_information" do expect(project.activity_1_information).to eq('More info about the first project') end
      it "stores activity_1_under_18" do expect(project.activity_1_under_18).to be_truthy end
      it "stores activity_2_summary" do expect(project.activity_2_summary).to eq('The second project') end
      it "stores activity_2_information" do expect(project.activity_2_information).to eq('More info about the second project') end
      it "stores activity_2_under_18" do expect(project.activity_2_under_18).to be_falsey end
      it "stores activity_3_summary" do expect(project.activity_3_summary).to eq('The third project') end
      it "stores activity_3_information" do expect(project.activity_3_information).to eq('More info about the third project') end
      it "stores activity_3_under_18" do expect(project.activity_3_under_18).to be_truthy end
      it "stores any_week" do expect(project.any_week).to be_falsey end
      it "stores week_1" do expect(project.week_1).to be_truthy end
      it "stores week_2" do expect(project.week_2).to be_falsey end
      it "stores week_3" do expect(project.week_3).to be_truthy end
      it "stores week_4" do expect(project.week_4).to be_falsey end
      it "stores evenings" do expect(project.evenings).to be_truthy end
      it "stores saturday" do expect(project.saturday).to be_falsey end
      it "stores notes" do expect(project.notes).to eq('More notes about the project') end
      it "stores adults" do expect(project.adults).to eq(10) end
      it "stores youth" do expect(project.youth).to eq(20) end
      it "stores kids" do expect(project.kids).to eq(30) end
      it "stores materials" do expect(project.materials).to eq('Paints and brushes') end
      it "stores leader" do expect(project.leader).to eq('Joe Bloggs') end
      it "stores morning_start_time" do expect(project.morning_start_time).to eq('09:30') end
      it "stores afternoon_start_time" do expect(project.afternoon_start_time).to eq('14:45') end
      it "stores evening_start_time" do expect(project.evening_start_time).to eq('19:15') end
      it "stores morning_slot_length" do expect(project.morning_slot_length).to eq(1.5) end
      it "stores afternoon_slot_length" do expect(project.afternoon_slot_length).to eq(2.5) end
      it "stores evening_slot_length" do expect(project.evening_slot_length).to eq(3.5) end
    end

    context "with invalid data" do
      def post_create
        attrs = FactoryBot.attributes_for(:project, :project_name => 'A')
        post :create, params: { project: attrs }
      end
      it "does not create a new record" do
        expect {
          post_create
        }.to_not change(Project, :count)
      end
      it "re-renders the form with the posted data" do
        post_create
        expect(response).to render_template(:edit)
        expect(assigns(:project).project_name).to eq('A')
      end
    end
  end


  describe "GET #edit" do

    let(:project) { FactoryBot.create(:default_project) }

    it "shows a record for editing" do
      get :edit, params: { id: project.id }
      expect(response).to render_template :edit
      expect(response).to have_http_status(:success)
      expect(assigns(:project).id).to eq(project.id)
    end

    it "raises an exception for a missing record" do
      assert_raises(ActiveRecord::RecordNotFound) do
        get :edit, params: { id: 99 }
      end
    end

  end


  describe "PUT #update" do

    context "with valid data" do

      let(:project) { FactoryBot.create(:default_project, :project_name => 'Original') }

      def post_update
        put :update, params: {id: project.id, project: { :project_name => 'Changed' } }
        project.reload
      end

      before(:each) do
        post_update
      end

      it "updates the project details" do
        expect(project.project_name).to eq('Changed')
      end

      it "redirects to the show action" do
        expect(response).to redirect_to(admin_project_path(assigns(:project)))
      end

      it "set a flash message" do
        expect(flash[:notice]).to eq('Project was updated successfully')
      end

    end

    context "with invalid data" do

      let(:project) { FactoryBot.create(:default_project, :project_name => 'Original') }

      def post_update
        put :update, params: { id: project.id, project: { :project_name => nil } }
        project.reload
      end

      before(:each) do
        post_update
      end

      it "does not update the project details" do
        expect(project.project_name).to eq('Original')
      end

      it "re-renders the form with the posted data" do
        expect(response).to render_template(:edit)
        expect(assigns(:project).project_name).to be_empty
      end

    end

  end


  describe "DELETE #destroy" do

    let!(:project) { FactoryBot.create(:default_project) }
    before do
      FactoryBot.create(:default_project_slot, project: project)
    end

    it "soft deletes the project" do
      expect {
        delete :destroy, params: { id: project.id }
      }.to change(Project, :count).by(-1)
      expect(Project.only_deleted.count).to eq(1)
    end

    it "soft deletes the project slots" do
      expect {
        delete :destroy, params: { id: project.id }
      }.to change(ProjectSlot, :count).by(-1)
      expect(ProjectSlot.only_deleted.count).to eq(1)
    end

    it "redirects to #index" do
      delete :destroy, params: { id: project.id }
      expect(response).to redirect_to([:admin,:projects])
    end

  end


  describe "GET #review" do

    let(:project) { FactoryBot.create(:default_project) }

    it "shows a record for editing" do
      get :review, params: { id: project.id }
      expect(response).to render_template :review
      expect(response).to have_http_status(:success)
      expect(assigns(:project).id).to eq(project.id)
    end
    it "raises an exception for a missing record" do
      assert_raises(ActiveRecord::RecordNotFound) do
        get :review, params: { id: 99 }
      end
    end
  end


  describe "PUT #do_review" do
    context "with valid data" do

      let(:project) { FactoryBot.create(:default_project) }

      def post_update
        put :do_review, params: {
          id: project.id,
          project: {
            adults:                4,
            youth:                 2,
            kids:                  1,
            materials:             'Stuff',
            activity_1_summary:     'The first project',
            activity_1_information: 'More info about the first project',
            activity_1_under_18:    true,
            activity_2_summary:     'The second project',
            activity_2_information: 'More info about the second project',
            activity_2_under_18:    true,
            activity_3_summary:     'The third project',
            activity_3_information: 'More info about the third project',
            activity_3_under_18:    true,
          }}
        project.reload
      end

      before(:each) do
        post_update
      end

      it "updates adults"                 do expect(project.adults).to                 eq(4) end
      it "updates youth"                  do expect(project.youth).to                  eq(2) end
      it "updates kids "                  do expect(project.kids).to                   eq(1) end
      it "updates materials"              do expect(project.materials).to              eq('Stuff') end
      it "updates activity_1_summary"     do expect(project.activity_1_summary).to     eq('The first project') end
      it "updates activity_1_information" do expect(project.activity_1_information).to eq('More info about the first project') end
      it "updates activity_1_under_18"    do expect(project.activity_1_under_18).to    be_truthy end
      it "updates activity_2_summary"     do expect(project.activity_2_summary).to     eq('The second project') end
      it "updates activity_2_information" do expect(project.activity_2_information).to eq('More info about the second project') end
      it "updates activity_2_under_18"    do expect(project.activity_2_under_18).to    be_truthy end
      it "updates activity_3_summary"     do expect(project.activity_3_summary).to     eq('The third project') end
      it "updates activity_3_information" do expect(project.activity_3_information).to eq('More info about the third project') end
      it "updates activity_3_under_18"    do expect(project.activity_3_under_18).to    be_truthy end

      it "redirects to the show action" do
        expect(response).to redirect_to(admin_project_path(assigns(:project)))
      end
      it "set a flash message" do
        expect(flash[:notice]).to eq('Project was updated successfully')
      end
    end

    context "with invalid data" do

      let(:project) { FactoryBot.create(:default_project, :adults => 10) }

      def post_update
        put :do_review, params: { id: project.id, project: { :adults => 0 } }
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

    let(:project) { FactoryBot.create(:default_project) }

    it "shows a record for editing" do
      get :summary, params: { id: project.id }
      expect(response).to render_template :summary
      expect(response).to have_http_status(:success)
      expect(assigns(:project).id).to eq(project.id)
    end
    it "raises an exception for a missing record" do
      assert_raises(ActiveRecord::RecordNotFound) do
        get :summary, params: { id: 99 }
      end
    end

  end


  describe "PUT #do_summary" do

    let(:project) { FactoryBot.create(:default_project) }

    def post_update
      put :do_summary, params: { id: project.id, project: { summary: 'Some summary text' } }
      project.reload
    end

    before(:each) do
      post_update
    end

    it "updates summary" do
      expect(project.summary).to eq('Some summary text')
    end

    it "redirects to the show action" do
      expect(response).to redirect_to(admin_project_path(assigns(:project)))
    end

    it "set a flash message" do
      expect(flash[:notice]).to eq('Project summary was updated successfully')
    end

  end


  describe "GET #publish" do

    let(:project) { FactoryBot.create(:default_project) }

    it "shows a record for editing" do
      get :publish, params: { id: project.id }
      expect(response).to render_template :publish
      expect(response).to have_http_status(:success)
      expect(assigns(:project).id).to eq(project.id)
    end
    it "raises an exception for a missing record" do
      assert_raises(ActiveRecord::RecordNotFound) do
        get :publish, params: { id: 99 }
      end
    end

  end


  describe "PUT #do_publish" do

    context "when a project is good to go" do
      let(:project) { FactoryBot.create(:good_to_publish_project) }
      def post_update
        put :do_publish, params: { id: project.id }
        project.reload
      end
      before(:each) do
        post_update
      end
      it "set the status to published" do
        expect(project.status).to eq(:published.to_s)
      end
      it "redirects to the show action" do
        expect(response).to redirect_to(admin_project_path(assigns(:project)))
      end
      it "set a flash message" do
        expect(flash[:notice]).to eq('Project was published')
      end
    end

    context "when a project is not ready to publish" do
      let(:project) { FactoryBot.create(:default_project) }
      def post_update
        put :do_publish, params: { id: project.id }
        project.reload
      end
      before(:each) do
        post_update
      end
      it "does not set the status to published" do
        expect(project.status).to_not eq(:published.to_s)
      end
      it "redirects to the publish action" do
        expect(response).to redirect_to(admin_publish_project_path(assigns(:project)))
      end
      it "set a flash message" do
        expect(flash[:error]).to eq('Project cannot be published')
      end
    end

  end


  describe "PUT #do_unpublish" do

    def post_update
      put :do_unpublish, params: { id: project.id }
      project.reload
    end

    context "when a project is published" do
      let(:project) { FactoryBot.create(:published_project) }
      before(:each) do
        post_update
      end
      it "sets the status to draft" do
        expect(project.status).to eq(:draft.to_s)
      end
      it "redirects to the show action" do
        expect(response).to redirect_to(admin_project_path(assigns(:project)))
      end
      it "set a flash message" do
        expect(flash[:notice]).to eq('Project was un-published')
      end
    end

    context "when a project is not published" do
      let(:project) { FactoryBot.create(:default_project) }
      before(:each) do
        post_update
      end
      it "does not change the status" do
        expect(project.status).to eq(:draft.to_s)
      end
      it "redirects to the show action" do
        expect(response).to redirect_to(admin_project_path(assigns(:project)))
      end
    end

  end


  describe "GET #compose_message" do

    context "with a valid project id" do
      let(:slot) { FactoryBot.create(:default_project_slot) }

      before(:each) do
        get :compose_message, params: { id: slot.project.id }
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end
      it "renders the :compose_message view" do
        expect(response).to render_template :compose_message
      end
      it "populates the project" do
        expect(assigns(:project)).to eq(slot.project)
      end
      it "populates an empty model" do
        expect(assigns(:ComposeMessage).class).to eq(ComposeMessage)
      end
    end

    context "with an invalid project id" do
      it "raises an exception" do
        assert_raises(ActiveRecord::RecordNotFound) do
          get :compose_message, params: { id: 99 }
        end
      end
    end

  end


  describe "GET #send_message" do

    let(:project) { FactoryBot.create(:default_project) }

    let(:slot1) { FactoryBot.create(:default_project_slot, project: project) }
    let(:slot2) { FactoryBot.create(:default_project_slot, project: project) }

    let(:vol1)  { FactoryBot.create(:default_volunteer, mobile: '1234') }
    let(:vol2)  { FactoryBot.create(:default_volunteer, mobile: '5678') }

    context "with an invalid message" do
      def send_message
        post :send_message, params: { id: project.id, compose_message: { message_text: nil } }
      end
      it "does not send a message" do
        expect {
          send_message
        }.to_not change(TextMessage, :count)
      end
      it "re-renders the form" do
        send_message
        expect(response).to render_template(:compose_message)
      end
    end

    context "with a valid message" do
      def send_message
        post :send_message, params: { id: project.id, compose_message: { message_text: 'Hello world' } }
      end

      before(:each) do
        slot1.volunteers << vol1
        slot1.volunteers << vol2
        slot2.volunteers << vol1
        slot2.volunteers << vol2
        send_message
      end

      it "sends a message" do
        expect {
          send_message
        }.to change(TextMessage, :count).by(1)
      end
      it "uses the message text provided" do
        expect(TextMessage.first.message).to eq('Hello world')
      end
      it "sends the message to each volunteer using the international mobile format" do
        expect(TextMessage.first.recipients).to be_in(['441234,445678','445678,441234'])
      end
      it "sets a success flash message" do
        expect(flash[:notice]).to eq('Message sent')
      end
      it "redirects to the project view" do
        expect(response).to redirect_to admin_project_url(project)
      end
    end
  end

end
