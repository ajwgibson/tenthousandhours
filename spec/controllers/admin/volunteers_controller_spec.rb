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

end
