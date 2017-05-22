require 'rails_helper'

RSpec.describe Admin::ProjectSlotsController, type: :controller do

  login_user

  let(:project) { FactoryGirl.create(:default_project) }


  describe "GET #index" do
    it "returns http success" do
      get :index, project_id: project.id
      expect(response).to have_http_status(:success)
    end
    it "renders the :index view" do
      get :index, project_id: project.id
      expect(response).to render_template :index
    end
    it "populates the project" do
      get :index, project_id: project.id
      expect(assigns(:project)).to eq(project)
    end
    it "populates an empty model" do
      get :index, project_id: project.id
      expect(assigns(:create_project_slot).class).to eq(CreateProjectSlot)
    end
  end


  describe "POST #create" do
    context "with invalid data" do
      def post_create
        attrs = FactoryGirl.attributes_for(:create_project_slot, start_date: 'A')
        post :create, { project_id: project.id, create_project_slot: attrs }
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
        attrs = FactoryGirl.attributes_for(:create_project_slot, start_date: 1.days.from_now.to_s, morning_slot: '1')
        post :create, { project_id: project.id, create_project_slot: attrs }
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

    let!(:slot) { FactoryGirl.create(:default_project_slot) }

    it "soft deletes the record" do
      expect {
        delete :destroy, :id => slot.id
      }.to change(ProjectSlot, :count).by(-1)
      expect(ProjectSlot.only_deleted.count).to eq(1)
    end

    it "redirects to #index" do
      project_id = slot.project.id
      delete :destroy, :id => slot.id
      expect(response).to redirect_to :action => :index,
                                      :project_id => project_id
    end

  end


  describe "GET #compose_message" do

    let(:slot) { FactoryGirl.create(:default_project_slot) }

    it "returns http success" do
      get :compose_message, id: slot.id
      expect(response).to have_http_status(:success)
    end

    it "renders the :compose_message view" do
      get :compose_message, id: slot.id
      expect(response).to render_template :compose_message
    end

    it "populates the project slot" do
      get :compose_message, id: slot.id
      expect(assigns(:ProjectSlot)).to eq(slot)
    end

    it "populates an empty model" do
      get :compose_message, id: slot.id
      expect(assigns(:ComposeMessage).class).to eq(ComposeMessage)
    end

    it "raises an exception for a missing record" do
      assert_raises(ActiveRecord::RecordNotFound) do
        get :compose_message, { id: 99 }
      end
    end

  end


  describe "GET #send_message" do

    let(:slot) { FactoryGirl.create(:default_project_slot) }

    let(:vol1) { FactoryGirl.create(:default_volunteer, mobile: '1234') }
    let(:vol2) { FactoryGirl.create(:default_volunteer, mobile: '5678') }

    context "with an invalid message" do
      def send_message
        post :send_message, { id: slot.id, compose_message: { message_text: nil } }
      end
      it "does not send a message" do
        expect {
          send_message
        }.to_not change(TextMessage, :count)
      end
      it "re-renders the form with the posted data and the project" do
        send_message
        expect(response).to render_template(:compose_message)
      end
    end

    context "with a valid message" do
      before(:each) do
        slot.volunteers << vol1
        slot.volunteers << vol2
        send_message
      end
      def send_message
        post :send_message, { id: slot.id, compose_message: { message_text: 'Hello world' } }
      end
      it "sends a message" do
        expect {
          send_message
        }.to change(TextMessage, :count).by(1)
      end
      it "uses the message text provided" do
        expect(TextMessage.first.message).to eq('Hello world')
      end
      it "sends the message to each slot volunteer using the international mobile format" do
        expect(TextMessage.first.recipients).to eq('441234,445678')
      end
      it "sets a success flash message" do
        expect(flash[:notice]).to eq('Message sent')
      end
      it "redirects to the show slot view" do
        expect(response).to redirect_to admin_show_project_slot_url(slot)
      end
    end
  end

end
