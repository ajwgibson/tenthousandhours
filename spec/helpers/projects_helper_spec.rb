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


  describe "project_start_times" do
    context "without_start_times" do
      let(:project) { FactoryGirl.create(:default_project) }
      it "returns nil" do
        output = helper.project_start_times(project)
        expect(output).to be_nil
      end
    end
    context "with_start_times" do
      let(:project) { FactoryGirl.create(:good_to_publish_project) }
      it "includes the start times" do
        output = helper.project_start_times(project)
        expect(output).to include('Morning start time')
        expect(output).to include('Afternoon start time')
        expect(output).to include('Evening start time')
      end
    end
  end

end
