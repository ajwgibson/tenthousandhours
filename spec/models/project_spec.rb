require 'rails_helper'

RSpec.describe Project, type: :model do

  it 'has a valid factory' do
    expect(FactoryGirl.build(:default_project)).to be_valid
  end

  # VALIDATION

  it "is invalid without an organisation type" do
    expect(FactoryGirl.build(:default_project, organisation_type: nil)).not_to be_valid
  end

  it "is invalid without an organisation name" do
    expect(FactoryGirl.build(:default_project, organisation_name: nil)).not_to be_valid
  end

end
