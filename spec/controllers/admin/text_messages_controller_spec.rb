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
      m = FactoryGirl.create(:default_text_message)
      get :index
      expect(assigns(:messages)).to eq([m])
    end
  end


  describe "GET #show" do

    let(:message) { FactoryGirl.create(:default_text_message, :message => 'My message') }

    it "shows a record" do
      get :show, { id: message.id }
      expect(response).to render_template :show
      expect(response).to have_http_status(:success)
      expect(assigns(:text_message).id).to eq(message.id)
    end
    it "raises an exception for a missing record" do
      assert_raises(ActiveRecord::RecordNotFound) do
        get :show, { id: 99 }
      end
    end
  end

end
