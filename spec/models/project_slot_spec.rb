require 'rails_helper'

RSpec.describe ProjectSlot, type: :model do

  it 'has a valid factory' do
    s = FactoryGirl.build(:default_project_slot)
    expect(s).to be_valid
  end


  # VALIDATION

  it "is not valid without a slot_date" do
    expect(FactoryGirl.build(:default_project_slot, slot_date: nil)).not_to be_valid
  end
  it "is not valid without a slot_type" do
    expect(FactoryGirl.build(:default_project_slot, slot_type: nil)).not_to be_valid
  end


  # METHODS

  describe "#selectable_slot_types" do
    it "returns humanized values" do
      expect(ProjectSlot.selectable_slot_types).to eq(
        [
          ['Morning',   'morning'],
          ['Afternoon', 'afternoon'],
          ['Evening',   'evening']
        ])
    end
  end

end
