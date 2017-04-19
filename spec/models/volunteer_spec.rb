require 'rails_helper'

RSpec.describe Volunteer, type: :model do

  it 'has a valid factory' do
    expect(FactoryGirl.build(:default_volunteer)).to be_valid
  end

  # VALIDATION

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

end
