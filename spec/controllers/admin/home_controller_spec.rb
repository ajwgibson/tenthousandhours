require 'rails_helper'

RSpec.describe Admin::HomeController, type: :controller do

  login_user

  describe "GET #index" do

    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end

    it "returns total_project_count" do
      FactoryBot.create(:default_project)
      FactoryBot.create(:default_project)
      FactoryBot.create(:default_project)
      get :index
      expect(assigns(:total_project_count)).to eq(3)
    end

    it "returns projects_by_organisation_type" do
      FactoryBot.create(:default_project, organisation_type: 'a')
      FactoryBot.create(:default_project, organisation_type: 'a')
      FactoryBot.create(:default_project, organisation_type: 'b')
      FactoryBot.create(:default_project, organisation_type: 'c')
      FactoryBot.create(:default_project, organisation_type: 'c')
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
      FactoryBot.create(:default_project, week_1:  true, any_week: false)
      FactoryBot.create(:default_project, week_1:  true, any_week: false)
      FactoryBot.create(:default_project, week_2: true, any_week: false)
      FactoryBot.create(:default_project, week_2: true, any_week: false)
      FactoryBot.create(:default_project, week_2: true, any_week: false)
      FactoryBot.create(:default_project, week_3: true, any_week: false)
      FactoryBot.create(:default_project, week_4: true, any_week: false)
      get :index
      expect(assigns(:projects_by_requested_week)).to eq(
        {
          'Week 1' => 2,
          'Week 2' => 3,
          'Week 3' => 1,
          'Week 4' => 1,
        }
      )
    end

    it "returns projects_by_evening" do
      FactoryBot.create(:default_project, evenings:  true)
      FactoryBot.create(:default_project, evenings:  false)
      FactoryBot.create(:default_project, evenings:  true)
      FactoryBot.create(:default_project, evenings:  false)
      FactoryBot.create(:default_project, evenings:  true)
      get :index
      expect(assigns(:projects_by_evening)).to eq(
        {
          'Yes' => 3,
          'No'  => 2,
        }
      )
    end

    it "returns projects_by_saturday" do
      FactoryBot.create(:default_project, saturday:  true)
      FactoryBot.create(:default_project, saturday:  false)
      FactoryBot.create(:default_project, saturday:  true)
      FactoryBot.create(:default_project, saturday:  false)
      FactoryBot.create(:default_project, saturday:  true)
      get :index
      expect(assigns(:projects_by_saturday)).to eq(
        {
          'Yes' => 3,
          'No'  => 2,
        }
      )
    end

    context "volunteer counts" do
      before do
        FactoryBot.create(:family_of_four_volunteer)
        FactoryBot.create(:family_of_four_volunteer)
        FactoryBot.create(:family_of_five_volunteer)
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
      let(:project) { FactoryBot.create(:published_project, morning_slot_length: 1.5, evening_slot_length: 2.5) }
      before do
        v1 = FactoryBot.create(:family_of_four_volunteer)
        v2 = FactoryBot.create(:family_of_five_volunteer)
        slot1 = FactoryBot.create(:default_project_slot, project: project, slot_type: :morning, extra_volunteers: 3)
        slot2 = FactoryBot.create(:default_project_slot, project: project, slot_type: :evening, extra_volunteers: 1)
        slot1.volunteers << v1
        slot2.volunteers << v2
      end
      it "returns the total number of committed hours" do
        get :index
        expect(assigns(:commitment)).to eq((4*1.5)+(3*1.5)+(5*2.5)+(1*2.5))
      end
    end

    context "personal projects" do
      context "with no personal projects" do
        it "returns zero counts" do
          get :index
          expect(assigns(:personal_project_count)).to eq(0)
          expect(assigns(:personal_project_volunteer_count)).to eq(0)
          expect(assigns(:personal_project_commitment)).to eq(0)
        end
      end
      context "with personal projects" do
        before(:each) do
          FactoryBot.create(:default_personal_project, duration: 1.5, volunteer_count: 10)
          FactoryBot.create(:default_personal_project, duration: 3.5, volunteer_count: 3)
          get :index
        end
        it "returns the total number of personal projects" do
          expect(assigns(:personal_project_count)).to eq(2)
        end
        it "returns the total number of volunteers expected for personal projects" do
          expect(assigns(:personal_project_volunteer_count)).to eq(13)
        end
        it "returns the total number of hours committed to personal projects" do
          expect(assigns(:personal_project_commitment)).to eq(25.5)
        end
      end
    end

    it "returns the number of youth who have not returned consent forms" do
      FactoryBot.create(:youth_volunteer, activity_consent_recorded_by: nil)
      FactoryBot.create(:youth_volunteer, activity_consent_recorded_by: 'someone')
      get :index
      expect(assigns(:activity_consent_required_count)).to eq(1)
    end
  end

end
