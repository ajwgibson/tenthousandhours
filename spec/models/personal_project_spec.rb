require 'rails_helper'

RSpec.describe PersonalProject, type: :model do

  it 'has a valid factory' do
    expect(FactoryGirl.build(:default_personal_project)).to be_valid
  end

  # VALIDATION

  context "validation" do
    it "is not valid without a project date" do
      expect(FactoryGirl.build(:default_personal_project, project_date: nil)).not_to be_valid
    end
    it "is not valid without a volunteer count" do
      expect(FactoryGirl.build(:default_personal_project, volunteer_count: nil)).not_to be_valid
      expect(FactoryGirl.build(:default_personal_project, volunteer_count: 'hello')).not_to be_valid
      expect(FactoryGirl.build(:default_personal_project, volunteer_count: 0)).not_to be_valid
    end
    it "is not valid without a duration" do
      expect(FactoryGirl.build(:default_personal_project, duration: nil)).not_to be_valid
      expect(FactoryGirl.build(:default_personal_project, duration: 'hello')).not_to be_valid
      expect(FactoryGirl.build(:default_personal_project, duration: 0)).not_to be_valid
    end
    it "is not valid without a description" do
      expect(FactoryGirl.build(:default_personal_project, description: nil)).not_to be_valid
    end
  end


  # METHODS

  describe "#commitment" do
    it "returns the duration time the volunteer_count" do
      pp = FactoryGirl.build(:default_personal_project, duration: 2.5, volunteer_count: 13)
      expect(pp.commitment).to eq(32.5)
    end
  end

end
