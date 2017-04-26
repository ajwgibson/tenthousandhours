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


  # SCOPES

  describe 'scope:for_week' do
    it 'includes records from the same week as the specified one' do
      a = FactoryGirl.create(:default_project_slot, :slot_date => Date.new(2017,7,3))
      b = FactoryGirl.create(:default_project_slot, :slot_date => Date.new(2017,7,10))
      c = FactoryGirl.create(:default_project_slot, :slot_date => Date.new(2017,7,4))
      d = FactoryGirl.create(:default_project_slot, :slot_date => Date.new(2017,7,2))
      e = FactoryGirl.create(:default_project_slot, :slot_date => Date.new(2017,7,9))
      filtered = ProjectSlot.for_week(Date.new(2017,7,4).cweek)
      expect(filtered).to     include(a,c,e)
      expect(filtered).not_to include(b,d)
    end
  end

  describe 'scope:for_date' do
    it 'includes records from the same date as the specified one' do
      a = FactoryGirl.create(:default_project_slot, :slot_date => Date.new(2017,7,3))
      b = FactoryGirl.create(:default_project_slot, :slot_date => Date.new(2017,7,10))
      filtered = ProjectSlot.for_date(Date.new(2017,7,10))
      expect(filtered).to     include(b)
      expect(filtered).not_to include(a)
    end
  end

  describe 'scope:of_type' do
    it 'includes records where the slot_type equals the specified one' do
      a = FactoryGirl.create(:default_project_slot, :slot_type => :evening)
      b = FactoryGirl.create(:default_project_slot, :slot_type => :morning)
      filtered = ProjectSlot.of_type(:morning)
      expect(filtered).to     include(b)
      expect(filtered).not_to include(a)
    end
  end

  describe 'scope:for_children' do
    it 'includes records for projects where activities are suitable for children' do
      project_a = FactoryGirl.create(:default_project, activity_1_under_18: true, kids: nil)
      project_b = FactoryGirl.create(:default_project, activity_1_under_18: true, kids: 0)
      project_c = FactoryGirl.create(:default_project, activity_1_under_18: true, kids: 1)
      a = FactoryGirl.create(:default_project_slot, project: project_a)
      b = FactoryGirl.create(:default_project_slot, project: project_b)
      c = FactoryGirl.create(:default_project_slot, project: project_c)
      filtered = ProjectSlot.for_children(true)
      expect(filtered).to     include(c)
      expect(filtered).not_to include(a,b)
    end
  end

  describe 'scope:for_youth' do
    it 'includes records for projects where activities are suitable for youth' do
      project_a = FactoryGirl.create(:default_project, activity_1_under_18: true, youth: nil)
      project_b = FactoryGirl.create(:default_project, activity_1_under_18: true, youth: 0)
      project_c = FactoryGirl.create(:default_project, activity_1_under_18: true, youth: 1)
      a = FactoryGirl.create(:default_project_slot, project: project_a)
      b = FactoryGirl.create(:default_project_slot, project: project_b)
      c = FactoryGirl.create(:default_project_slot, project: project_c)
      filtered = ProjectSlot.for_youth(true)
      expect(filtered).to     include(c)
      expect(filtered).not_to include(a,b)
    end
  end

  describe 'scope:with_project_name' do
    it 'includes records for projects whose name matches the specified value' do
      aaa    = FactoryGirl.create(:default_project, project_name: 'aaa')
      bab    = FactoryGirl.create(:default_project, project_name: 'bab')
      bbb    = FactoryGirl.create(:default_project, project_name: 'bbb')
      a = FactoryGirl.create(:default_project_slot, project: aaa)
      b = FactoryGirl.create(:default_project_slot, project: bab)
      c = FactoryGirl.create(:default_project_slot, project: bbb)
      filtered = ProjectSlot.with_project_name('a')
      expect(filtered).not_to  include(c)
      expect(filtered).to      include(a,b)
    end
  end
  

end
