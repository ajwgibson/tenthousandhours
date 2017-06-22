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


  describe "#volunteer_count" do
    it "returns the sum of the volunteers signed up" do
      slot = FactoryGirl.build(:default_project_slot)
      slot.volunteers << FactoryGirl.build(:default_volunteer, family: '[{"age_category":"adult"},{"age_category":"youth"},{"age_category":"child"}]')
      slot.volunteers << FactoryGirl.build(:default_volunteer, family: '[{"age_category":"youth"},{"age_category":"child"}]')
      slot.volunteers << FactoryGirl.build(:default_volunteer, family: '[{"age_category":"adult"},{"age_category":"youth"},{"age_category":"child"}]')
      expect(slot.volunteer_count).to eq(11)
    end
  end


  describe "#adults" do
    it "returns the sum of the adult volunteers signed up" do
      slot = FactoryGirl.build(:default_project_slot)
      slot.volunteers << FactoryGirl.build(:default_volunteer, family: '[{"age_category":"adult"},{"age_category":"youth"},{"age_category":"child"}]')
      slot.volunteers << FactoryGirl.build(:default_volunteer, family: '[{"age_category":"youth"},{"age_category":"child"}]')
      slot.volunteers << FactoryGirl.build(:default_volunteer, family: '[{"age_category":"adult"},{"age_category":"youth"},{"age_category":"child"}]')
      expect(slot.adults).to eq(5)
    end
  end


  describe "adult_cover" do
    context "when the project.adults value is set" do
      it "returns the fraction of the required adults as a percentage" do
        project = FactoryGirl.build(:default_project, adults: 9)
        slot    = FactoryGirl.build(:default_project_slot, project: project)
        slot.volunteers << FactoryGirl.build(:default_volunteer)
        slot.volunteers << FactoryGirl.build(:default_volunteer)
        slot.volunteers << FactoryGirl.build(:default_volunteer)
        expect(slot.adult_cover).to eq(33)
      end
    end
    context "when the project.adults value is not set" do
      it "returns 0" do
        project = FactoryGirl.build(:default_project, adults: nil)
        slot    = FactoryGirl.build(:default_project_slot, project: project)
        slot.volunteers << FactoryGirl.build(:default_volunteer)
        expect(slot.adult_cover).to eq(0)
      end
    end
  end


  describe "#youth" do
    it "returns the sum of the youth volunteers signed up" do
      slot = FactoryGirl.build(:default_project_slot)
      slot.volunteers << FactoryGirl.build(:default_volunteer, family: '[{"age_category":"youth"},{"age_category":"child"}]')
      slot.volunteers << FactoryGirl.build(:default_volunteer, family: '[{"age_category":"child"}]')
      slot.volunteers << FactoryGirl.build(:default_volunteer, family: '[{"age_category":"adult"},{"age_category":"youth"},{"age_category":"child"}]')
      expect(slot.youth).to eq(2)
    end
  end


  describe "#children" do
    it "returns the sum of the child volunteers signed up" do
      slot = FactoryGirl.build(:default_project_slot)
      slot.volunteers << FactoryGirl.build(:default_volunteer, family: '[{"age_category":"child"},{"age_category":"child"}]')
      slot.volunteers << FactoryGirl.build(:default_volunteer, family: '[{"age_category":"youth"}]')
      slot.volunteers << FactoryGirl.build(:default_volunteer, family: '[{"age_category":"adult"},{"age_category":"youth"},{"age_category":"child"}]')
      expect(slot.children).to eq(3)
    end
  end


  describe "#start_time" do
    context "when the slot is in the morning" do
      let(:project) { FactoryGirl.build(:default_project) }
      let(:slot) { FactoryGirl.build(:default_project_slot, slot_type: :morning, project: project) }
      context "when the project morning_start_time is not set" do
        it "returns 'tbc'" do
          project.morning_start_time = nil
          expect(slot.start_time).to eq('tbc')
        end
      end
      context "when the project morning_start_time value is set" do
        before do
          project.morning_start_time = '09:00'
        end
        it "returns the project morning_start_time value" do
          expect(slot.start_time).to eq('09:00')
        end
      end
    end
    context "when the slot is in the afternoon" do
      let(:project) { FactoryGirl.build(:default_project) }
      let(:slot) { FactoryGirl.build(:default_project_slot, slot_type: :afternoon, project: project) }
      context "when the project afternoon_start_time is not set" do
        it "returns 'tbc'" do
          project.afternoon_start_time = nil
          expect(slot.start_time).to eq('tbc')
        end
      end
      context "when the project afternoon_start_time value is set" do
        before do
          project.afternoon_start_time = '14:30'
        end
        it "returns the project afternoon_start_time value" do
          expect(slot.start_time).to eq('14:30')
        end
      end
    end
    context "when the slot is in the evening" do
      let(:project) { FactoryGirl.build(:default_project) }
      let(:slot) { FactoryGirl.build(:default_project_slot, slot_type: :evening, project: project) }
      context "when the project evening_start_time is not set" do
        it "returns 'tbc'" do
          project.evening_start_time = nil
          expect(slot.start_time).to eq('tbc')
        end
      end
      context "when the project evening_start_time value is set" do
        before do
          project.evening_start_time = '19:45'
        end
        it "returns the project evening_start_time value" do
          expect(slot.start_time).to eq('19:45')
        end
      end
    end
  end


  describe "#slot_length" do
    let(:project) {
      FactoryGirl.build(
        :default_project,
        morning_slot_length: 1.5,
        afternoon_slot_length: 2.5,
        evening_slot_length: 3.5
      )
    }
    context "when the slot is in the morning" do
      let(:slot) { FactoryGirl.build(:default_project_slot, slot_type: :morning, project: project) }
      context "when the project morning_slot_length value is set" do
        it "returns the project morning_slot_length value" do
          expect(slot.slot_length).to eq(1.5)
        end
      end
      context "when the project morning_slot_length value is not set" do
        before { slot.project.morning_slot_length = nil }
        it "returns zero" do
          expect(slot.slot_length).to eq(0)
        end
      end
    end
    context "when the slot is in the afternoon" do
      let(:slot) { FactoryGirl.build(:default_project_slot, slot_type: :afternoon, project: project) }
      context "when the project afternoon_slot_length value is set" do
        it "returns the project afternoon_slot_length value" do
          expect(slot.slot_length).to eq(2.5)
        end
      end
      context "when the project afternoon_slot_length value is not set" do
        before { slot.project.afternoon_slot_length = nil }
        it "returns zero" do
          expect(slot.slot_length).to eq(0)
        end
      end
    end
    context "when the slot is in the evening" do
      let(:slot) { FactoryGirl.build(:default_project_slot, slot_type: :evening, project: project) }
      context "when the project evening_slot_length value is set" do
        it "returns the project evening_slot_length value" do
          expect(slot.slot_length).to eq(3.5)
        end
      end
      context "when the project evening_slot_length value is not set" do
        before { slot.project.evening_slot_length = nil }
        it "returns zero" do
          expect(slot.slot_length).to eq(0)
        end
      end
    end
  end


  describe "#end_time" do
    let(:slot) { FactoryGirl.build(:default_project_slot) }
    context "when the slot_length is not set" do
      it "returns 'tbc'" do
        allow(slot).to receive(:slot_length) { 0 }
        expect(slot.end_time).to eq('tbc')
      end
    end
    context "when the slot start_time is not set" do
      it "returns 'tbc'" do
        allow(slot).to receive(:start_time) { 'tbc' }
        expect(slot.end_time).to eq('tbc')
      end
    end
    context "when the slot start_time and slot_length are both set" do
      it "returns the start_time plus the slot_length" do
        allow(slot).to receive(:start_time)  { '09:30' }
        allow(slot).to receive(:slot_length) { 1.5 }
        expect(slot.end_time).to eq('11:00')
      end
    end
  end


  describe "#can_sign_up?(volunteer)" do
    context "when the volunteer is a youth" do
      let(:volunteer) { FactoryGirl.build(:default_volunteer, age_category: 'youth') }
      context "when the project is not suitable for youth" do
        let(:project) { FactoryGirl.build(:default_project, youth: 0) }
        let(:slot) { FactoryGirl.build(:default_project_slot, project: project) }
        it "returns false" do
          expect(slot.can_sign_up?(volunteer)).to be_falsey
        end
      end
      context "when the project is suitable for youth" do
        let(:project) { FactoryGirl.build(:default_project, youth: 1) }
        let(:slot) { FactoryGirl.build(:default_project_slot, project: project) }
        context "when the project is already full of youth" do
          before do
            slot.volunteers << FactoryGirl.build(:default_volunteer, age_category: 'youth')
          end
          it "returns false" do
            expect(slot.can_sign_up?(volunteer)).to be_falsey
          end
        end
        context "when the project still has youth places available" do
          it "returns true" do
            expect(slot.can_sign_up?(volunteer)).to be_truthy
          end
        end
      end
    end
    context "when the volunteer is an adult" do
      let(:volunteer) { FactoryGirl.build(:default_volunteer, age_category: 'adult') }
      let(:project) { FactoryGirl.build(:default_project, adults: 1) }
      let(:slot) { FactoryGirl.build(:default_project_slot, project: project) }
      context "when the project is already full" do
        before do
          slot.volunteers << FactoryGirl.build(:default_volunteer, age_category: 'adult')
        end
        it "returns false" do
          expect(slot.can_sign_up?(volunteer)).to be_falsey
        end
      end
      context "when the project still has places available" do
        it "returns true" do
          expect(slot.can_sign_up?(volunteer)).to be_truthy
        end
      end
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
