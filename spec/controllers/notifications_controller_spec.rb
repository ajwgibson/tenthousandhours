require 'rails_helper'

RSpec.describe NotificationsController, type: :controller do

  login_basic

  describe "GET #reminders" do

    let(:project_a)   { FactoryGirl.create(:published_project, project_name: 'Project A') }
    let(:project_b)   { FactoryGirl.create(:default_project,   project_name: 'Project B') }
    let(:volunteer_a) { FactoryGirl.create(:default_volunteer, first_name:   'AAA') }
    let(:volunteer_b) { FactoryGirl.create(:default_volunteer, first_name:   'BBB') }
    let(:slot1)  { FactoryGirl.create(:default_project_slot, project: project_a, slot_date:  1.days.from_now, slot_type:  :morning) }
    let(:slot1a) { FactoryGirl.create(:default_project_slot, project: project_a, slot_date:  1.days.from_now, slot_type:  :afternoon) }
    let(:slot1b) { FactoryGirl.create(:default_project_slot, project: project_b, slot_date:  1.days.from_now, slot_type:  :afternoon) }
    let(:slot2)  { FactoryGirl.create(:default_project_slot, project: project_a, slot_date:  2.days.from_now, slot_type:  :morning) }
    let(:slot3)  { FactoryGirl.create(:default_project_slot, project: project_a, slot_date: -1.days.from_now, slot_type:  :morning) }

    before(:each) do
      slot1.volunteers << volunteer_a
      slot2.volunteers << volunteer_a
      slot3.volunteers << volunteer_a
    end

    it "returns http success" do
      get :reminders
      expect(response).to have_http_status(:success)
    end

    it "returns a text message with the count of reminders sent" do
      get :reminders
      expect(response.body).to eq('1 reminder sent')
    end

    it "sends a reminder for tomorrow's project slots" do
      expect {
        get :reminders
      }.to change(TextMessage, :count).by(1)
    end

    it "includes the volunteer first name in the message" do
      get :reminders
      expect(TextMessage.first.message).to include('AAA')
    end

    it "includes the project name in the message" do
      get :reminders
      expect(TextMessage.first.message).to include('Project A')
    end

    it "includes the slot date in the message" do
      get :reminders
      expect(TextMessage.first.message).to include(1.days.from_now.strftime('%d/%m/%Y'))
    end

    it "includes the slot time in the message" do
      get :reminders
      expect(TextMessage.first.message).to include('09:30')
    end

    context "when a volunteer is serving more than once that day on the same project" do
      before do
        slot1a.volunteers << volunteer_a
      end
      it "only sends a message for the first slot" do
        get :reminders
        expect(TextMessage.count).to eq(1)
        expect(TextMessage.first.message).to include('09:30')
        expect(TextMessage.first.message).not_to include('14:00')
      end
    end

    context "when a volunteer is serving more than once that day on different projects" do
      before do
        slot1b.volunteers << volunteer_a
      end
      it "sends a message for each project" do
        get :reminders
        expect(TextMessage.count).to eq(2)
        recipients = TextMessage.pluck(:recipients).uniq
        expect(recipients.count).to eq(1)
        expect(recipients[0]).to eq(volunteer_a.mobile_international_format)
      end
    end

    context "when more than one volunteer is serving" do
      before(:each) do
        slot1.volunteers << volunteer_b
      end
      it "sends a message to each volunteer" do
        get :reminders
        expect(TextMessage.count).to eq(2)
        recipients = TextMessage.pluck(:recipients)
        expect(recipients).to include(volunteer_a.mobile_international_format)
        expect(recipients).to include(volunteer_b.mobile_international_format)
      end
      it "returns a text message with the count of reminders sent" do
        get :reminders
        expect(response.body).to eq('2 reminders sent')
      end
    end

  end

end
