require 'rails_helper'

RSpec.describe Admin::SlotsController, type: :controller do

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
    it "populates an array of slots" do
      slot = FactoryGirl.create(:default_project_slot)
      get :index
      expect(assigns(:slots)).to eq([slot])
    end
    it "orders slots by project_name by default" do
      project_b = FactoryGirl.create(:default_project, project_name: 'b')
      project_a = FactoryGirl.create(:default_project, project_name: 'a')
      slot_b = FactoryGirl.create(:default_project_slot, project: project_b)
      slot_a = FactoryGirl.create(:default_project_slot, project: project_a)
      get :index
      expect(assigns(:slots)).to eq([slot_a, slot_b])
    end
    it "stores filters to the session" do
      get :index, with_project_name: 'abc'
      expect(session[:filter_admin_slots]).to eq({'with_project_name' => 'abc'})
    end
    it "removes blank filter values" do
      get :index, with_project_name: nil
      expect(assigns(:filter)).to eq({})
    end
    it "retrieves filters from the session if none have been supplied" do
      a = FactoryGirl.create(:default_project_slot, slot_type: 'evening')
      b = FactoryGirl.create(:default_project_slot, slot_type: 'morning')
      get :index, { }, { :filter_admin_slots => {'of_type' => 'evening'} }
      expect(assigns(:slots)).to eq([a])
    end
    it "applies the 'order_by' parameter" do
      project_b = FactoryGirl.create(:default_project, project_name: 'b')
      project_a = FactoryGirl.create(:default_project, project_name: 'a')
      slot_b = FactoryGirl.create(:default_project_slot, project: project_b)
      slot_a = FactoryGirl.create(:default_project_slot, project: project_a)
      get :index, order_by: 'projects.project_name desc'
      expect(assigns(:slots)).to eq([slot_b, slot_a])
    end
    it "applies the 'with_project_name' parameter" do
      project_b = FactoryGirl.create(:default_project, project_name: 'b')
      project_a = FactoryGirl.create(:default_project, project_name: 'a')
      slot_b = FactoryGirl.create(:default_project_slot, project: project_b)
      slot_a = FactoryGirl.create(:default_project_slot, project: project_a)
      get :index, with_project_name: 'a'
      expect(assigns(:slots)).to eq([slot_a])
    end
    it "applies the 'for_week' filter" do
      a = FactoryGirl.create(:default_project_slot, slot_date: Date.new(2017,1,1))
      b = FactoryGirl.create(:default_project_slot, slot_date: Date.new(2017,1,21))
      get :index, for_week: Date.new(2017,1,1).cweek
      expect(assigns(:slots)).to eq([a])
    end
    it "applies the 'for_date' filter" do
      a = FactoryGirl.create(:default_project_slot, slot_date: Date.new(2017,1,1))
      b = FactoryGirl.create(:default_project_slot, slot_date: Date.new(2017,1,21))
      get :index, for_date: Date.new(2017,1,1)
      expect(assigns(:slots)).to eq([a])
    end
    it "applies the 'of_type' filter" do
      a = FactoryGirl.create(:default_project_slot, slot_type: 'evening')
      b = FactoryGirl.create(:default_project_slot, slot_type: 'morning')
      get :index, of_type: 'evening'
      expect(assigns(:slots)).to eq([a])
    end
    context "with no explicit page value" do
      it "returns the first page of slots" do
        30.times do |i|
          FactoryGirl.create(:default_project_slot)
        end
        get :index
        expect(assigns(:slots).count).to eq(25)
      end
    end
    context "with an explicit page value" do
      it "returns the requested page of slots" do
        30.times do |i|
          FactoryGirl.create(:default_project_slot)
        end
        get :index, page: 2
        expect(assigns(:slots).count).to eq(5)
      end
    end
  end


  describe "GET #clear_filter" do
    it "redirects to #index" do
      get :clear_filter
      expect(response).to redirect_to([:admin, :slots])
    end
    it "clears the session entry" do
      session[:filter_admin_slots] = {'with_project_name' => 'abc'}
      get :clear_filter
      expect(session.key?(:filter_admin_slots)).to be false
    end
  end


  describe "GET #show" do
    let(:slot) { FactoryGirl.create(:default_project_slot) }
    it "shows a record" do
      get :show, { id: slot.id }
      expect(response).to render_template :show
      expect(response).to have_http_status(:success)
      expect(assigns(:ProjectSlot).id).to eq(slot.id)
    end
    it "raises an exception for a missing record" do
      assert_raises(ActiveRecord::RecordNotFound) do
        get :show, { id: 99 }
      end
    end
  end


  describe "GET #edit" do
    let(:slot) { FactoryGirl.create(:default_project_slot) }
    it "shows a record for editing" do
      get :edit, { id: slot.id }
      expect(response).to render_template :edit
      expect(response).to have_http_status(:success)
      expect(assigns(:ProjectSlot).id).to eq(slot.id)
    end
    it "raises an exception for a missing record" do
      assert_raises(ActiveRecord::RecordNotFound) do
        get :edit, { id: 99 }
      end
    end
  end


  describe "PUT #update" do
    context "with valid data" do
      let(:slot) { FactoryGirl.create(:default_project_slot, extra_volunteers: 0) }
      def post_update
        put :update, :id => slot.id, :project_slot => { :extra_volunteers => 5 }
        slot.reload
      end
      before(:each) do
        post_update
      end
      it "updates the slot details" do
        expect(slot.extra_volunteers).to eq(5)
      end
      it "redirects to the show action" do
        expect(response).to redirect_to(admin_slot_path(assigns(:ProjectSlot)))
      end
      it "set a flash message" do
        expect(flash[:notice]).to eq('Project slot was updated successfully')
      end
    end
    context "with invalid data" do
      let(:slot) { FactoryGirl.create(:default_project_slot, :extra_volunteers => 5) }
      def post_update
        put :update, :id => slot.id, :project_slot => { :extra_volunteers => nil }
        slot.reload
      end
      before(:each) do
        post_update
      end
      it "does not update the slot details" do
        expect(slot.extra_volunteers).to eq(5)
      end
      it "re-renders the form with the posted data" do
        expect(response).to render_template(:edit)
        expect(assigns(:ProjectSlot).extra_volunteers).to be_nil
      end
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
        expect(response).to redirect_to admin_slot_url(slot)
      end
    end
  end


end
