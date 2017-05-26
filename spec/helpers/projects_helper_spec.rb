require 'rails_helper'

RSpec.describe ProjectsHelper, type: :helper do

  describe "project_dates" do

    let(:project) { FactoryGirl.create(:default_project) }

    context "when the start date and end date have not been decided yet" do
      it "returns nil" do
        output = helper.project_dates(project)
        expect(output).to eq(nil)
      end
    end

    context "when the start date and end date are the same" do
      before do
        FactoryGirl.create(:default_project_slot, slot_date: '01/01/2018', project: project)
      end
      it "only includes the start date" do
        output = helper.project_dates(project)
        expect(output).to include('1st January')
      end
    end

    context "when the start date and end date are different but in the same month" do
      before do
        FactoryGirl.create(:default_project_slot, slot_date: '02/02/2018', project: project)
        FactoryGirl.create(:default_project_slot, slot_date: '03/02/2018', project: project)
      end
      it "includes the start and end dates and the month" do
        output = helper.project_dates(project)
        expect(output).to include('2nd to 3rd February')
      end
    end
  end


  describe "styled_project_dates" do
    let(:project) { FactoryGirl.create(:default_project) }
    before do
      FactoryGirl.create(:default_project_slot, slot_date: '01/01/2018', project: project)
    end
    it "wraps the project_dates output with strong and em tags" do
      output = helper.styled_project_dates(project)
      expect(output).to include("<strong><em>#{helper.project_dates(project)}</em></strong>")
    end
  end


  describe "slot_times" do
    let(:slot) { FactoryGirl.build(:default_project_slot) }
    context "with no start_time" do
      before(:each) do
        allow(slot).to receive(:start_time) { 'tbc' }
      end
      it "returns 'tbc'" do
        output = helper.slot_times(slot)
        expect(output).to eq('tbc')
      end
    end
    context "with no end_time" do
      before(:each) do
        allow(slot).to receive(:start_time) { '09:30' }
        allow(slot).to receive(:end_time) { 'tbc' }
      end
      it "returns just the start time" do
        output = helper.slot_times(slot)
        expect(output).to eq('09:30')
      end
    end
    context "with both start_time and end_time" do
      before(:each) do
        allow(slot).to receive(:start_time) { '09:30' }
        allow(slot).to receive(:end_time) { '11:45' }
      end
      it "returns 'start_time to end_time'" do
        output = helper.slot_times(slot)
        expect(output).to eq('09:30 to 11:45')
      end
    end
  end

end
