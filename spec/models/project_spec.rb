require 'rails_helper'

RSpec.describe Project, type: :model do

  it 'has a valid factory' do
    expect(FactoryGirl.build(:default_project)).to be_valid
  end


  # VALIDATION

  it "is not valid without an organisation type" do
    expect(FactoryGirl.build(:default_project, organisation_type: nil)).not_to be_valid
  end

  it "is not valid without a project name" do
    expect(FactoryGirl.build(:default_project, project_name: nil)).not_to be_valid
  end

  it "is not valid when adults is not a number" do
    expect(FactoryGirl.build(:default_project, adults: 'yes')).not_to be_valid
  end
  it "is not valid when adults < 2" do
    expect(FactoryGirl.build(:default_project, adults: 1)).not_to be_valid
  end
  it "is not valid when adults is not a whole number" do
    expect(FactoryGirl.build(:default_project, adults: 2.5)).not_to be_valid
  end
  it "is valid when adults >= 2" do
    expect(FactoryGirl.build(:default_project, adults: 2)).to be_valid
  end
  it "is valid when adults is nil" do
    expect(FactoryGirl.build(:default_project, adults: nil)).to be_valid
  end

  it "is not valid when youth is not a number" do
    expect(FactoryGirl.build(:default_project, youth: 'yes')).not_to be_valid
  end
  it "is not valid when youth < 0" do
    expect(FactoryGirl.build(:default_project, youth: -1)).not_to be_valid
  end
  it "is not valid when youth is not a whole number" do
    expect(FactoryGirl.build(:default_project, youth: 2.5)).not_to be_valid
  end
  it "is valid when youth >= 0" do
    expect(FactoryGirl.build(:default_project, youth: 2, activity_1_under_18: true)).to be_valid
  end
  it "is valid when youth is nil" do
    expect(FactoryGirl.build(:default_project, youth: nil)).to be_valid
  end

  it "is not valid when youth is > zero but none of the activities are suitable for under 18s" do
    expect(FactoryGirl.build(:default_project,
                              activity_1_under_18: false,
                              activity_2_under_18: false,
                              activity_3_under_18: false,
                              youth: 1)).not_to be_valid
  end

  it "is not valid when kids is not a number" do
    expect(FactoryGirl.build(:default_project, kids: 'yes')).not_to be_valid
  end
  it "is not valid when kids < 0" do
    expect(FactoryGirl.build(:default_project, kids: -1)).not_to be_valid
  end
  it "is not valid when kids is not a whole number" do
    expect(FactoryGirl.build(:default_project, kids: 2.5)).not_to be_valid
  end
  it "is valid when kids >= 0" do
    expect(FactoryGirl.build(:default_project, kids: 2, activity_1_under_18: true)).to be_valid
  end
  it "is valid when kids is nil" do
    expect(FactoryGirl.build(:default_project, kids: nil)).to be_valid
  end

  it "is not valid when kids is > zero but none of the activities are suitable for under 18s" do
    expect(FactoryGirl.build(:default_project,
                              activity_1_under_18: false,
                              activity_2_under_18: false,
                              activity_3_under_18: false,
                              kids: 1)).not_to be_valid
  end

  it "is not valid when morning_start_time is not a valid 24 hour clock time" do
    expect(FactoryGirl.build(:default_project, morning_start_time: 'abc')).not_to be_valid
    expect(FactoryGirl.build(:default_project, morning_start_time: '9 am')).not_to be_valid
    expect(FactoryGirl.build(:default_project, morning_start_time: '24:00')).not_to be_valid
    expect(FactoryGirl.build(:default_project, morning_start_time: '00:00')).to be_valid
    expect(FactoryGirl.build(:default_project, morning_start_time: '23:59')).to be_valid
  end

  it "is not valid when afternoon_start_time is not a valid 24 hour clock time" do
    expect(FactoryGirl.build(:default_project, afternoon_start_time: 'abc')).not_to be_valid
    expect(FactoryGirl.build(:default_project, afternoon_start_time: '9 am')).not_to be_valid
    expect(FactoryGirl.build(:default_project, afternoon_start_time: '24:00')).not_to be_valid
    expect(FactoryGirl.build(:default_project, afternoon_start_time: '00:00')).to be_valid
    expect(FactoryGirl.build(:default_project, afternoon_start_time: '23:59')).to be_valid
  end

  it "is not valid when evening_start_time is not a valid 24 hour clock time" do
    expect(FactoryGirl.build(:default_project, evening_start_time: 'abc')).not_to be_valid
    expect(FactoryGirl.build(:default_project, evening_start_time: '9 am')).not_to be_valid
    expect(FactoryGirl.build(:default_project, evening_start_time: '24:00')).not_to be_valid
    expect(FactoryGirl.build(:default_project, evening_start_time: '00:00')).to be_valid
    expect(FactoryGirl.build(:default_project, evening_start_time: '23:59')).to be_valid
  end

  # IMPORT

  describe "#import" do

    def clear_uploads
      FileUtils.rm Dir.glob(Rails.root.join('public', 'uploads', '*'))
    end

    def file_fixture(file)
      Rails.root.join('spec', 'fixtures', 'files', file)
    end

    before(:each) do
      clear_uploads
    end

    after(:each) do
      clear_uploads
    end

    context "for an file with the wrong headers" do
      it "throws an exception with 'Invalid format'" do
        expect { Project.import(file_fixture('project_imports/invalid_headers.csv')) }.to raise_error('Invalid format')
      end
    end

    context "for a file with a mixture of valid and invalid records" do
      it "throws an exception with 'Invalid data'" do
        expect { Project.import(file_fixture('project_imports/invalid_records.csv')) }.to raise_error('Invalid data')
      end
      it "does not add any records" do
        expect { Project.import(file_fixture('project_imports/invalid_records.csv')) rescue nil }.not_to change{Project.count}
      end
    end

    context "for a valid file" do
      let(:project) { Project.first }
      before do
        Project.import(file_fixture('project_imports/pre_school.csv'))
      end
      it "captures typeform_id" do
        expect(project.typeform_id).to eq('1234')
      end
      it "captures organisation_type" do
        expect(project.organisation_type).to eq('Pre-school')
      end
      it "captures contact_name" do
        expect(project.contact_name).to eq('Mr John Smith')
      end
      it "captures contact_role" do
        expect(project.contact_role).to eq('Principal')
      end
      it "captures contact_email" do
        expect(project.contact_email).to eq('john.smith@dummy.net')
      end
      it "captures contact_phone" do
        expect(project.contact_phone).to eq('02870123456')
      end
      it "captures activity_1_summary" do
        expect(project.activity_1_summary).to eq('Gardening and general tidy-up')
      end
      it "captures activity_1_information" do
        expect(project.activity_1_information).to eq('This could contain all sorts of stuff. Including full stops.')
      end
      it "captures activity_1_under_18" do
        expect(project.activity_1_under_18).to be_truthy
      end
      it "captures activity_2_summary" do
        expect(project.activity_2_summary).to eq('Painting and decorating')
      end
      it "captures activity_2_information" do
        expect(project.activity_2_information).to eq('Please use nice colours.')
      end
      it "captures activity_2_under_18" do
        expect(project.activity_2_under_18).to be_falsey
      end
      it "captures activity_3_summary" do
        expect(project.activity_3_summary).to eq('Mural painting')
      end
      it "captures activity_3_information" do
        expect(project.activity_3_information).to eq('Like the one you did somewhere else.')
      end
      it "captures activity_3_under_18" do
        expect(project.activity_3_under_18).to be_truthy
      end
      it "captures any_week" do
        expect(project.any_week).to be_truthy
      end
      it "does not capture july_3 when any_week is true" do
        expect(project.july_3).to be_falsey
      end
      it "does not capture july_10 when any_week is true" do
        expect(project.july_10).to be_falsey
      end
      it "does not capture july_17 when any_week is true" do
        expect(project.july_17).to be_falsey
      end
      it "does not capture july_24 when any_week is true" do
        expect(project.july_24).to be_falsey
      end
      it "captures evenings" do
        expect(project.evenings).to be_truthy
      end
      it "captures saturday" do
        expect(project.saturday).to be_truthy
      end
      it "captures notes" do
        expect(project.notes).to eq('Possibly some notes here.')
      end
      it "captures submitted_at" do
        expect(project.submitted_at).to eq(DateTime.new(2017,3,15,12,28))
      end
    end

    context "for a pre-school project" do
      let(:project) { Project.first }
      before do
        Project.import(file_fixture('project_imports/pre_school.csv'))
      end
      it "captures project_name from the pre-school name" do
        expect(project.project_name).to eq('Causeway Coast Pre-school')
      end
    end

    context "for a school project" do
      let(:project) { Project.first }
      before do
        Project.import(file_fixture('project_imports/school.csv'))
      end
      it "captures project_name from the school name" do
        expect(project.project_name).to eq('Causeway Coast School')
      end
    end

    context "for an agency/charity project" do
      let(:project) { Project.first }
      before do
        Project.import(file_fixture('project_imports/agency_charity.csv'))
      end
      it "captures project_name from the agency name" do
        expect(project.project_name).to eq('Causeway Agency')
      end
    end

    context "for a business project" do
      let(:project) { Project.first }
      before do
        Project.import(file_fixture('project_imports/business.csv'))
      end
      it "captures project_name from the business name" do
        expect(project.project_name).to eq('Causeway Business')
      end
    end

    context "for a residential centre project" do
      let(:project) { Project.first }
      before do
        Project.import(file_fixture('project_imports/residential.csv'))
      end
      it "captures project_name from the residential centre name" do
        expect(project.project_name).to eq('Causeway Residential')
      end
    end

    context "for a project with alternative contact details" do
      let(:project) { Project.first }
      before do
        Project.import(file_fixture('project_imports/alternative_contact.csv'))
      end
      it "captures contact_name" do
        expect(project.contact_name).to eq('Mr John Smith')
      end
      it "captures contact_role" do
        expect(project.contact_role).to eq('Principal')
      end
      it "captures contact_email" do
        expect(project.contact_email).to eq('john.smith@dummy.net')
      end
      it "captures contact_phone" do
        expect(project.contact_phone).to eq('02870123456')
      end
    end

    context "for a project with date preferences" do
      let(:project) { Project.first }
      before do
        Project.import(file_fixture('project_imports/specified_dates.csv'))
      end
      it "captures the july_3 flag" do
        expect(project.july_3).to be_truthy
      end
      it "captures the july_10 flag" do
        expect(project.july_10).to be_truthy
      end
      it "captures the july_17 flag" do
        expect(project.july_17).to be_truthy
      end
      it "captures the july_24 flag" do
        expect(project.july_24).to be_truthy
      end
    end

    context "for an existing project" do
      let(:project) { Project.first }
      before do
        Project.create!({ typeform_id: '1234', organisation_type: 'School', project_name: 'A school' })
        Project.import(file_fixture('project_imports/pre_school.csv'))
      end
      it "does not create a new record" do
        expect(Project.count).to eq(1)
      end
      it "does not update the existing project" do
        expect(project.project_name).to eq('A school')
      end
    end

  end


  # UTILITY CODE

  describe "#start_date" do
    context "with no slots" do
      let(:project) { FactoryGirl.build(:default_project) }
      it "returns nil" do
        expect(project.start_date).to eq(nil)
      end
    end
    context "with slots" do
      let(:project) { FactoryGirl.create(:default_project) }
      before do
        FactoryGirl.create(:default_project_slot, slot_date: 5.days.from_now.to_s, project: project)
        FactoryGirl.create(:default_project_slot, slot_date: 2.days.from_now.to_s, project: project)
      end
      it "returns the date of the earliest slot" do
        expect(project.start_date).to eq(2.days.from_now.to_date)
      end
    end
  end

  describe "#end_date" do
    context "with no slots" do
      let(:project) { FactoryGirl.build(:default_project) }
      it "returns nil" do
        expect(project.end_date).to eq(nil)
      end
    end
    context "with slots" do
      let(:project) { FactoryGirl.create(:default_project) }
      before do
        FactoryGirl.create(:default_project_slot, slot_date: 5.days.from_now.to_s, project: project)
        FactoryGirl.create(:default_project_slot, slot_date: 2.days.from_now.to_s, project: project)
      end
      it "returns the date of the latest slot" do
        expect(project.end_date).to eq(5.days.from_now.to_date)
      end
    end
  end


  describe "#can_publish?" do
    context "when a project is good to go" do
      it "returns true" do
        project = FactoryGirl.create(:good_to_publish_project)
        expect(project.can_publish?).to eq(true)
      end
    end
    context "when a project has no slots" do
      it "returns false" do
        project = FactoryGirl.create(:default_project, adults: 10, summary: 'Something')
        expect(project.can_publish?).to eq(false)
      end
    end
    context "when a project has morning slots but no morning start time" do
      it "returns false" do
        project = FactoryGirl.create(:good_to_publish_project, morning_start_time: nil)
        expect(project.can_publish?).to eq(false)
      end
    end
    context "when a project has afternoon slots but no afternoon start time" do
      it "returns false" do
        project = FactoryGirl.create(:good_to_publish_project, afternoon_start_time: nil)
        expect(project.can_publish?).to eq(false)
      end
    end
    context "when a project has evening slots but no evening start time" do
      it "returns false" do
        project = FactoryGirl.create(:good_to_publish_project, evening_start_time: nil)
        expect(project.can_publish?).to eq(false)
      end
    end
    context "when a project has no summary" do
      it "returns false" do
        project = FactoryGirl.create(:good_to_publish_project, summary: '')
        expect(project.can_publish?).to eq(false)
      end
    end
    context "when a project has no adult quota set" do
      it "returns false" do
        project = FactoryGirl.create(:good_to_publish_project, adults: nil)
        expect(project.can_publish?).to eq(false)
      end
    end
    context "when a project has no leader" do
      it "returns false" do
        project = FactoryGirl.create(:good_to_publish_project, leader: nil)
        expect(project.can_publish?).to eq(false)
      end
    end
  end


  describe "#suitable_for_youth?" do
    context "when the youth counter is nil" do
      it "returns false" do
        project = FactoryGirl.build(:default_project, youth: nil)
        expect(project.suitable_for_youth?).to eq(false)
      end
    end
    context "when the youth counter is zero" do
      it "returns false" do
        project = FactoryGirl.build(:default_project, youth: 0)
        expect(project.suitable_for_youth?).to eq(false)
      end
    end
    context "when the youth counter is more than zero" do
      it "returns true" do
        project = FactoryGirl.build(:default_project, youth: 1)
        expect(project.suitable_for_youth?).to eq(true)
      end
    end
  end

  describe "#suitable_for_kids?" do
    context "when the kids counter is nil" do
      it "returns false" do
        project = FactoryGirl.build(:default_project, kids: nil)
        expect(project.suitable_for_kids?).to eq(false)
      end
    end
    context "when the kids counter is zero" do
      it "returns false" do
        project = FactoryGirl.build(:default_project, kids: 0)
        expect(project.suitable_for_kids?).to eq(false)
      end
    end
    context "when the kids counter is more than zero" do
      it "returns true" do
        project = FactoryGirl.build(:default_project, kids: 1)
        expect(project.suitable_for_kids?).to eq(true)
      end
    end
  end


  #
  # SCOPES
  #
  describe 'scope:could_run_wc_july_3rd' do
    it 'includes records with july_3 set true' do
      a    = FactoryGirl.create(:default_project, :july_3 => true , any_week: false)
      b    = FactoryGirl.create(:default_project, :july_3 => false, any_week: false)
      filtered = Project.could_run_wc_july_3rd(true)
      expect(filtered).to include(a)
      expect(filtered).not_to include(b)
    end
    it 'includes records with any_week set true' do
      a    = FactoryGirl.create(:default_project, july_3: false, any_week: true)
      b    = FactoryGirl.create(:default_project, july_3: false, any_week: false)
      filtered = Project.could_run_wc_july_3rd(true)
      expect(filtered).to include(a)
      expect(filtered).not_to include(b)
    end
  end
  describe 'scope:could_run_wc_july_10th' do
    it 'includes records with july_10 set true' do
      a    = FactoryGirl.create(:default_project, :july_10 => true , any_week: false)
      b    = FactoryGirl.create(:default_project, :july_10 => false, any_week: false)
      filtered = Project.could_run_wc_july_10th(true)
      expect(filtered).to include(a)
      expect(filtered).not_to include(b)
    end
    it 'includes records with any_week set true' do
      a    = FactoryGirl.create(:default_project, july_10: false, any_week: true)
      b    = FactoryGirl.create(:default_project, july_10: false, any_week: false)
      filtered = Project.could_run_wc_july_10th(true)
      expect(filtered).to include(a)
      expect(filtered).not_to include(b)
    end
  end
  describe 'scope:could_run_wc_july_17th' do
    it 'includes records with july_17 set true' do
      a    = FactoryGirl.create(:default_project, :july_17 => true , any_week: false)
      b    = FactoryGirl.create(:default_project, :july_17 => false, any_week: false)
      filtered = Project.could_run_wc_july_17th(true)
      expect(filtered).to include(a)
      expect(filtered).not_to include(b)
    end
    it 'includes records with any_week set true' do
      a    = FactoryGirl.create(:default_project, july_17: false, any_week: true)
      b    = FactoryGirl.create(:default_project, july_17: false, any_week: false)
      filtered = Project.could_run_wc_july_17th(true)
      expect(filtered).to include(a)
      expect(filtered).not_to include(b)
    end
  end
  describe 'scope:could_run_wc_july_24th' do
    it 'includes records with july_24 set true' do
      a    = FactoryGirl.create(:default_project, :july_24 => true , any_week: false)
      b    = FactoryGirl.create(:default_project, :july_24 => false, any_week: false)
      filtered = Project.could_run_wc_july_24th(true)
      expect(filtered).to include(a)
      expect(filtered).not_to include(b)
    end
    it 'includes records with any_week set true' do
      a    = FactoryGirl.create(:default_project, july_24: false, any_week: true)
      b    = FactoryGirl.create(:default_project, july_24: false, any_week: false)
      filtered = Project.could_run_wc_july_24th(true)
      expect(filtered).to include(a)
      expect(filtered).not_to include(b)
    end
  end
  describe 'scope:could_run_evenings' do
    it 'includes records with evenings set true' do
      a    = FactoryGirl.create(:default_project, evenings: true)
      b    = FactoryGirl.create(:default_project, evenings: false)
      filtered = Project.could_run_evenings(true)
      expect(filtered).to include(a)
      expect(filtered).not_to include(b)
    end
  end
  describe 'scope:could_run_saturday' do
    it 'includes records with saturday set true' do
      a    = FactoryGirl.create(:default_project, saturday: true)
      b    = FactoryGirl.create(:default_project, saturday: false)
      filtered = Project.could_run_saturday(true)
      expect(filtered).to include(a)
      expect(filtered).not_to include(b)
    end
  end
  describe 'scope:with_name' do
    it 'includes records where the project_name contains the value' do
      aaa    = FactoryGirl.create(:default_project, project_name: 'aaa')
      bab    = FactoryGirl.create(:default_project, project_name: 'bab')
      bbb    = FactoryGirl.create(:default_project, project_name: 'bbb')
      filtered = Project.with_name('a')
      expect(filtered).to include(aaa)
      expect(filtered).to include(bab)
      expect(filtered).not_to include(bbb)
    end
  end
  describe 'scope:of_type' do
    it 'includes records where the organisation_type matches the value' do
      a    = FactoryGirl.create(:default_project, organisation_type: 'a')
      b    = FactoryGirl.create(:default_project, organisation_type: 'b')
      filtered = Project.of_type('a')
      expect(filtered).to include(a)
      expect(filtered).not_to include(b)
    end
  end
  describe 'scope:with_status' do
    it 'includes records where the status matches the value' do
      a    = FactoryGirl.create(:default_project, status: :draft)
      b    = FactoryGirl.create(:default_project, status: :published)
      filtered = Project.with_status(Project.statuses[:draft])
      expect(filtered).to include(a)
      expect(filtered).not_to include(b)
    end
  end

end
