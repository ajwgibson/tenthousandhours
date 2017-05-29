require 'rails_helper'

RSpec.describe Admin::VolunteersController, type: :controller do

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
    it "populates an array of volunteers" do
      v = FactoryGirl.create(:default_volunteer)
      get :index
      expect(assigns(:volunteers)).to eq([v])
    end
  end


  describe "GET #show" do

    let(:volunteer) { FactoryGirl.create(:default_volunteer, :email => 'a@a.com') }

    it "shows a record" do
      get :show, { id: volunteer.id }
      expect(response).to render_template :show
      expect(response).to have_http_status(:success)
      expect(assigns(:volunteer).id).to eq(volunteer.id)
    end
    it "raises an exception for a missing record" do
      assert_raises(ActiveRecord::RecordNotFound) do
        get :show, { id: 99 }
      end
    end
  end


  describe "GET #compose_one" do

    context "with a valid volunteer id" do
      let(:volunteer) { FactoryGirl.create(:default_volunteer) }

      before(:each) do
        get :compose_one, { id: volunteer.id }
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end
      it "renders the :compose_one view" do
        expect(response).to render_template :compose_one
      end
      it "populates the volunteer" do
        expect(assigns(:volunteer)).to eq(volunteer)
      end
      it "populates an empty model" do
        expect(assigns(:ComposeMessage).class).to eq(ComposeMessage)
      end
    end

    it "raises an exception for a missing record" do
      assert_raises(ActiveRecord::RecordNotFound) do
        get :compose_one, { id: 99 }
      end
    end

  end


  describe "POST #send_one" do

    let(:volunteer) { FactoryGirl.create(:default_volunteer, mobile: '1234') }

    context "with an invalid message" do
      def send_message
        post :send_one, { id: volunteer.id, compose_message: { message_text: nil } }
      end
      it "does not send a message" do
        expect {
          send_message
        }.to_not change(TextMessage, :count)
      end
      it "re-renders the form with the posted data" do
        send_message
        expect(response).to render_template(:compose_one)
      end
    end

    context "with a valid message" do
      def send_message
        post :send_one, { id: volunteer.id, compose_message: { message_text: 'Hello world' } }
      end

      before(:each) do
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
      it "sends the message to the volunteer using the international mobile format" do
        expect(TextMessage.first.recipients).to eq('441234')
      end
      it "sets a success flash message" do
        expect(flash[:notice]).to eq('Message sent')
      end
      it "redirects to the show volunteer view" do
        expect(response).to redirect_to admin_volunteer_url(volunteer)
      end
    end
  end


  describe "GET #compose_all" do
    before do
      FactoryGirl.create(:default_volunteer)
      FactoryGirl.create(:default_volunteer)
    end

    before(:each) do
      get :compose_all
    end

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end
    it "renders the :compose_all view" do
      expect(response).to render_template :compose_all
    end
    it "populates the volunteer count" do
      expect(assigns(:volunteer_count)).to eq(Volunteer.count)
    end
    it "populates an empty model" do
      expect(assigns(:ComposeMessage).class).to eq(ComposeMessage)
    end
  end


  describe "POST #send_all" do

    context "with an invalid message" do
      def send_message
        post :send_all, { compose_message: { message_text: nil } }
      end
      it "does not send a message" do
        expect {
          send_message
        }.to_not change(TextMessage, :count)
      end
      it "re-renders the form with the posted data" do
        send_message
        expect(response).to render_template(:compose_all)
      end
    end

    context "with a valid message" do
      def send_message
        post :send_all, { compose_message: { message_text: 'Hello world' } }
      end

      before do
        FactoryGirl.create(:default_volunteer, mobile: '1111')
        FactoryGirl.create(:default_volunteer, mobile: '2222')
        FactoryGirl.create(:default_volunteer, mobile: '3333')
      end

      before(:each) do
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
      it "sends the message to all volunteers using the international mobile format" do
        expect(TextMessage.first.recipients).to eq('441111,442222,443333')
      end
      it "sets a success flash message" do
        expect(flash[:notice]).to eq('Message sent')
      end
      it "redirects to the volunteers view" do
        expect(response).to redirect_to admin_volunteers_url
      end
    end
  end

end
