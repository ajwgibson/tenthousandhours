require 'rails_helper'

RSpec.describe Volunteer, type: :model do

  it 'has a valid factory' do
    expect(FactoryGirl.build(:default_volunteer)).to be_valid
  end


  # VALIDATION

  it "is not valid without a first_name" do
    expect(FactoryGirl.build(:default_volunteer, first_name: nil)).not_to be_valid
  end
  it "is not valid without a last_name" do
    expect(FactoryGirl.build(:default_volunteer, last_name: nil)).not_to be_valid
  end
  it "is not valid without an mobile" do
    expect(FactoryGirl.build(:default_volunteer, mobile: nil)).not_to be_valid
  end
  it "is not valid without an age_category" do
    expect(FactoryGirl.build(:default_volunteer, age_category: nil)).not_to be_valid
  end


  # METHODS

  describe "#humanized_age_category" do
    it "returns 'Over 18' when age_category is 'adult'" do
      v = FactoryGirl.build(:default_volunteer, age_category: 'adult')
      expect(v.humanized_age_category).to eq('Over 18')
    end
    it "returns '11 to 18' when age_category is 'youth'" do
      v = FactoryGirl.build(:default_volunteer, age_category: 'youth')
      expect(v.humanized_age_category).to eq('11 to 18')
    end
    it "returns 'under 11' when age_category is 'child'" do
      v = FactoryGirl.build(:default_volunteer, age_category: 'child')
      expect(v.humanized_age_category).to eq('Under 11')
    end
    it "returns nil when age_category is nil" do
      v = FactoryGirl.build(:default_volunteer, age_category: nil)
      expect(v.humanized_age_category).to eq(nil)
    end
  end

end
