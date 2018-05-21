require 'rails_helper'

RSpec.describe Admin::TextMessagesController, type: :controller do

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
    it "populates an array of messages" do
      m = FactoryBot.create(:default_text_message)
      get :index
      expect(assigns(:messages)).to eq([m])
    end
    context "with no explicit page value" do
      it "returns the first page of text messages" do
        30.times do |i|
          FactoryBot.create(:default_text_message)
        end
        get :index
        expect(assigns(:messages).count).to eq(25)
      end
    end
    context "with an explicit page value" do
      it "returns the requested page of text messages" do
        30.times do |i|
          FactoryBot.create(:default_text_message)
        end
        get :index, params: { page: 2 }
        expect(assigns(:messages).count).to eq(5)
      end
    end
    it "orders messages by date by default" do
      a = FactoryBot.create(:default_text_message, created_at: 3.days.ago)
      b = FactoryBot.create(:default_text_message, created_at: 1.days.ago)
      c = FactoryBot.create(:default_text_message, created_at: 5.days.ago)
      get :index
      expect(assigns(:messages)).to eq([b,a,c])
    end
    it "stores filters to the session" do
      get :index, params: { with_recipient: 'abc' }
      expect(session[:filter_admin_text_messages]).to eq({'with_recipient' => 'abc'})
    end
    it "removes blank filter values" do
      get :index, params: { with_recipient: nil }
      expect(assigns(:filter)).to eq({})
    end
    it "retrieves filters from the session if none have been supplied" do
      a = FactoryBot.create(:default_text_message, recipients: 'a')
      b = FactoryBot.create(:default_text_message, recipients: 'b')
      get :index, session: { :filter_admin_text_messages => {'with_recipient' => 'a'} }
      expect(assigns(:messages)).to eq([a])
    end
    it "applies the 'with_recipient' filter if supplied" do
      a = FactoryBot.create(:default_text_message, recipients: 'a')
      b = FactoryBot.create(:default_text_message, recipients: 'b')
      get :index, params: { with_recipient: 'a' }
      expect(assigns(:messages)).to eq([a])
    end
  end


  describe "GET #clear_filter" do
    it "redirects to #index" do
      get :clear_filter
      expect(response).to redirect_to([:admin, :text_messages])
    end
    it "clears the session entry" do
      session[:filter_admin_text_messages] = {'with_recipient' => 'abc'}
      get :clear_filter
      expect(session.key?(:filter_admin_text_messages)).to be false
    end
  end


  describe "GET #show" do

    let(:message) { FactoryBot.create(:default_text_message, :message => 'My message') }

    it "shows a record" do
      get :show, params: { id: message.id }
      expect(response).to render_template :show
      expect(response).to have_http_status(:success)
      expect(assigns(:text_message).id).to eq(message.id)
    end
    it "raises an exception for a missing record" do
      assert_raises(ActiveRecord::RecordNotFound) do
        get :show, params: { id: 99 }
      end
    end
  end

end
