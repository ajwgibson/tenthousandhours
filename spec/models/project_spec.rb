require 'rails_helper'

RSpec.describe Project, type: :model do

  it 'has a valid factory' do
    expect(FactoryGirl.build(:default_project)).to be_valid
  end


  # VALIDATION

  it "is not valid without an organisation type" do
    expect(FactoryGirl.build(:default_project, organisation_type: nil)).not_to be_valid
  end

  it "is not valid without an organisation name" do
    expect(FactoryGirl.build(:default_project, organisation_name: nil)).not_to be_valid
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
    expect(FactoryGirl.build(:default_project, youth: 2, project_1_under_18: true)).to be_valid
  end
  it "is valid when youth is nil" do
    expect(FactoryGirl.build(:default_project, youth: nil)).to be_valid
  end

  it "is not valid when youth is > zero but none of the sub-projects are for youth" do
    expect(FactoryGirl.build(:default_project,
                              project_1_under_18: false,
                              project_2_under_18: false,
                              project_3_under_18: false,
                              youth: 1)).not_to be_valid
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
      it "captures project_1_summary" do
        expect(project.project_1_summary).to eq('Gardening and general tidy-up')
      end
      it "captures project_1_information" do
        expect(project.project_1_information).to eq('This could contain all sorts of stuff. Including full stops.')
      end
      it "captures project_1_under_18" do
        expect(project.project_1_under_18).to be_truthy
      end
      it "captures project_2_summary" do
        expect(project.project_2_summary).to eq('Painting and decorating')
      end
      it "captures project_2_information" do
        expect(project.project_2_information).to eq('Please use nice colours.')
      end
      it "captures project_2_under_18" do
        expect(project.project_2_under_18).to be_falsey
      end
      it "captures project_3_summary" do
        expect(project.project_3_summary).to eq('Mural painting')
      end
      it "captures project_3_information" do
        expect(project.project_3_information).to eq('Like the one you did somewhere else.')
      end
      it "captures project_3_under_18" do
        expect(project.project_3_under_18).to be_truthy
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
      it "captures organisation_name from the pre-school name" do
        expect(project.organisation_name).to eq('Causeway Coast Pre-school')
      end
    end

    context "for a school project" do
      let(:project) { Project.first }
      before do
        Project.import(file_fixture('project_imports/school.csv'))
      end
      it "captures organisation_name from the school name" do
        expect(project.organisation_name).to eq('Causeway Coast School')
      end
    end

    context "for an agency/charity project" do
      let(:project) { Project.first }
      before do
        Project.import(file_fixture('project_imports/agency_charity.csv'))
      end
      it "captures organisation_name from the agency name" do
        expect(project.organisation_name).to eq('Causeway Agency')
      end
    end

    context "for a business project" do
      let(:project) { Project.first }
      before do
        Project.import(file_fixture('project_imports/business.csv'))
      end
      it "captures organisation_name from the business name" do
        expect(project.organisation_name).to eq('Causeway Business')
      end
    end

    context "for a residential centre project" do
      let(:project) { Project.first }
      before do
        Project.import(file_fixture('project_imports/residential.csv'))
      end
      it "captures organisation_name from the residential centre name" do
        expect(project.organisation_name).to eq('Causeway Residential')
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
        Project.create!({ typeform_id: '1234', organisation_type: 'School', organisation_name: 'A school' })
        Project.import(file_fixture('project_imports/pre_school.csv'))
      end
      it "does not create a new record" do
        expect(Project.count).to eq(1)
      end
      it "updates the existing project" do
        expect(project.organisation_name).to eq('Causeway Coast Pre-school')
      end
    end

  end

end
