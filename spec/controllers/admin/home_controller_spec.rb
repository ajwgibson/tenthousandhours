require 'rails_helper'

RSpec.describe Admin::HomeController, type: :controller do

  login_user

  describe "GET #index" do
    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end

    it "returns projects_by_organisation_type" do
      FactoryGirl.create(:default_project, organisation_type: 'a')
      FactoryGirl.create(:default_project, organisation_type: 'a')
      FactoryGirl.create(:default_project, organisation_type: 'b')
      FactoryGirl.create(:default_project, organisation_type: 'c')
      FactoryGirl.create(:default_project, organisation_type: 'c')
      get :index
      expect(assigns(:projects_by_organisation_type)).to eq(
        {
          'a' => 2,
          'b' => 1,
          'c' => 2
        }
      )
    end

    it "returns projects_by_requested_week" do
      FactoryGirl.create(:default_project, july_3:  true, any_week: false)
      FactoryGirl.create(:default_project, july_3:  true, any_week: false)
      FactoryGirl.create(:default_project, july_10: true, any_week: false)
      FactoryGirl.create(:default_project, july_10: true, any_week: false)
      FactoryGirl.create(:default_project, july_10: true, any_week: false)
      FactoryGirl.create(:default_project, july_17: true, any_week: false)
      FactoryGirl.create(:default_project, july_24: true, any_week: false)
      get :index
      expect(assigns(:projects_by_requested_week)).to eq(
        {
          'July 3rd'  => 2,
          'July 10th' => 3,
          'July 17th' => 1,
          'July 24th' => 1,
        }
      )
    end

    it "returns projects_by_evening" do
      FactoryGirl.create(:default_project, evenings:  true)
      FactoryGirl.create(:default_project, evenings:  false)
      FactoryGirl.create(:default_project, evenings:  true)
      FactoryGirl.create(:default_project, evenings:  false)
      FactoryGirl.create(:default_project, evenings:  true)
      get :index
      expect(assigns(:projects_by_evening)).to eq(
        {
          'Yes' => 3,
          'No'  => 2,
        }
      )
    end

    it "returns projects_by_saturday" do
      FactoryGirl.create(:default_project, saturday:  true)
      FactoryGirl.create(:default_project, saturday:  false)
      FactoryGirl.create(:default_project, saturday:  true)
      FactoryGirl.create(:default_project, saturday:  false)
      FactoryGirl.create(:default_project, saturday:  true)
      get :index
      expect(assigns(:projects_by_saturday)).to eq(
        {
          'Yes' => 3,
          'No'  => 2,
        }
      )
    end

    it "returns projects_cumulative" do
      FactoryGirl.create(:default_project, submitted_at:  Date.new(2017, 4, 1))
      FactoryGirl.create(:default_project, submitted_at:  Date.new(2017, 4, 1))
      FactoryGirl.create(:default_project, submitted_at:  Date.new(2017, 4, 2))
      FactoryGirl.create(:default_project, submitted_at:  Date.new(2017, 4, 3))
      FactoryGirl.create(:default_project, submitted_at:  Date.new(2017, 4, 3))
      FactoryGirl.create(:default_project, submitted_at:  Date.new(2017, 4, 3))
      FactoryGirl.create(:default_project, submitted_at:  Date.new(2017, 4, 4))
      FactoryGirl.create(:default_project, submitted_at:  Date.new(2017, 4, 5))
      FactoryGirl.create(:default_project, submitted_at:  Date.new(2017, 4, 5))
      FactoryGirl.create(:default_project, submitted_at:  Date.new(2017, 4, 6))
      get :index
      expect(assigns(:projects_cumulative)).to eq(
        {
          '01/04/2017' => 2,
          '02/04/2017' => 3,
          '03/04/2017' => 6,
          '04/04/2017' => 7,
          '05/04/2017' => 9,
          '06/04/2017' => 10,
        }
      )
    end

    context "volunteer counts" do
      before do
        FactoryGirl.create(:family_of_four_volunteer)
        FactoryGirl.create(:family_of_four_volunteer)
        FactoryGirl.create(:family_of_five_volunteer)
      end
      it "returns the number of adult volunteers" do
        get :index
        expect(assigns(:volunteer_adults)).to eq(6)
      end
      it "returns the number of youth volunteers" do
        get :index
        expect(assigns(:volunteer_youth)).to eq(3)
      end
      it "returns the number of child volunteers" do
        get :index
        expect(assigns(:volunteer_children)).to eq(4)
      end
    end

    context "commitment" do
      let(:project) { FactoryGirl.create(:published_project, morning_slot_length: 1.5, evening_slot_length: 2.5) }
      before do
        v1 = FactoryGirl.create(:family_of_four_volunteer)
        v2 = FactoryGirl.create(:family_of_five_volunteer)
        slot1 = FactoryGirl.create(:default_project_slot, project: project, slot_type: :morning)
        slot2 = FactoryGirl.create(:default_project_slot, project: project, slot_type: :evening)
        slot1.volunteers << v1
        slot2.volunteers << v2
      end
      it "returns the total number of committed hours" do
        get :index
        expect(assigns(:commitment)).to eq((4*1.5)+(5*2.5))
      end
    end

  end

end
