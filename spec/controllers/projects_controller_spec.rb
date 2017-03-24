require 'rails_helper'

RSpec.describe ProjectsController, type: :controller do

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

end
