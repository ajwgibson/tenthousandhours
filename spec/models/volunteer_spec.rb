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


  # CALLBACKS

  describe "#before_validation" do
    it "strips leading zeros and spaces from the mobile number" do
      v = FactoryGirl.build(:default_volunteer, mobile: '0012 3  40')
      v.valid?
      expect(v.mobile).to eq('12340')
    end
    it "handles an empty mobile number gracefully" do
      v = FactoryGirl.build(:default_volunteer, mobile: nil)
      v.valid?
      expect(v.mobile).to eq(nil)
    end
  end


  # METHODS

  describe "#humanized_age_category" do
    it "returns 'Adult - Over 18' when age_category is 'adult'" do
      v = FactoryGirl.build(:default_volunteer, age_category: 'adult')
      expect(v.humanized_age_category).to eq('Adult - over 18')
    end
    it "returns 'Youth - 11 to 18' when age_category is 'youth'" do
      v = FactoryGirl.build(:default_volunteer, age_category: 'youth')
      expect(v.humanized_age_category).to eq('Youth - 11 to 18')
    end
    it "returns 'Child - under 11' when age_category is 'child'" do
      v = FactoryGirl.build(:default_volunteer, age_category: 'child')
      expect(v.humanized_age_category).to eq('Child - under 11')
    end
    it "returns nil when age_category is nil" do
      v = FactoryGirl.build(:default_volunteer, age_category: nil)
      expect(v.humanized_age_category).to eq(nil)
    end
  end


  describe "#adults_in_family" do
    context "when the volunteer is an adult" do
      let(:volunteer) { FactoryGirl.build(:default_volunteer, age_category: 'adult') }
      context "when the volunteer has no family" do
        it "returns 1" do
          expect(volunteer.adults_in_family).to eq(1)
        end
      end
      context "when the volunteer has family that includes adults" do
        it "counts the volunteer and the other adults in the family" do
          volunteer.family = '[{"name":"a","age_category":"adult"},{"name":"b","age_category":"youth"},{"name":"c","age_category":"child"}]'
          expect(volunteer.adults_in_family).to eq(2)
        end
      end
    end
    context "when the volunteer is not an adult" do
      let(:volunteer) { FactoryGirl.build(:default_volunteer, age_category: 'youth') }
      context "when the volunteer has no family" do
        it "returns 0" do
          expect(volunteer.adults_in_family).to eq(0)
        end
      end
      context "when the volunteer has family that includes adults" do
        it "counts the other adults in the family" do
          volunteer.family = '[{"name":"a","age_category":"adult"},{"name":"b","age_category":"youth"},{"name":"c","age_category":"child"}]'
          expect(volunteer.adults_in_family).to eq(1)
        end
      end
    end
  end

  describe "#youth_in_family" do
    context "when the volunteer is a youth" do
      let(:volunteer) { FactoryGirl.build(:default_volunteer, age_category: 'youth') }
      context "when the volunteer has no family" do
        it "returns 1" do
          expect(volunteer.youth_in_family).to eq(1)
        end
      end
      context "when the volunteer has family that includes youth" do
        it "counts the volunteer and the other youth in the family" do
          volunteer.family = '[{"name":"a","age_category":"adult"},{"name":"b","age_category":"youth"},{"name":"c","age_category":"child"}]'
          expect(volunteer.youth_in_family).to eq(2)
        end
      end
    end
    context "when the volunteer is not a youth" do
      let(:volunteer) { FactoryGirl.build(:default_volunteer, age_category: 'adult') }
      context "when the volunteer has no family" do
        it "returns 0" do
          expect(volunteer.youth_in_family).to eq(0)
        end
      end
      context "when the volunteer has family that includes youth" do
        it "counts the other youth in the family" do
          volunteer.family = '[{"name":"a","age_category":"adult"},{"name":"b","age_category":"youth"},{"name":"c","age_category":"child"}]'
          expect(volunteer.youth_in_family).to eq(1)
        end
      end
    end
  end

  describe "#children_in_family" do
    let(:volunteer) {
      FactoryGirl.build(
        :default_volunteer, age_category: 'adult',
        family: '[{"name":"a","age_category":"child"},{"name":"b","age_category":"child"},{"name":"c","age_category":"child"}]')
      }
    it "counts the children in the family" do
      expect(volunteer.children_in_family).to eq(3)
    end
  end

  describe "#family_size" do
    let(:volunteer) {
      FactoryGirl.build(
        :default_volunteer, age_category: 'adult',
        family: '[{"name":"a","age_category":"adult"},{"name":"b","age_category":"child"},{"name":"c","age_category":"youth"}]')
      }
    it "counts the total number of people in the family" do
      expect(volunteer.family_size).to eq(4)
    end
  end

  describe "#commitment" do
    context "with no project slots" do
      let(:volunteer) { FactoryGirl.build(:family_of_four_volunteer) }
      it "returns zero" do
        expect(volunteer.commitment).to eq(0)
      end
    end
    context "with project slots" do
      let(:project)   { FactoryGirl.build(:published_project) }
      let(:volunteer) { FactoryGirl.build(:family_of_four_volunteer) }
      before do
        project.project_slots.each { |slot| slot << volunteer }
      end
      it "returns the total hours for all slots times the family size" do
        expected = project.project_slots.inject(0) { |sum,slot| sum + slot.slot_length } * volunteer.family_size
        expect(volunteer.commitment).to eq(expected)
      end
    end
  end

  describe "#personal_project_commitment" do
    context "with no personal projects" do
      let(:volunteer) { FactoryGirl.build(:default_volunteer) }
      it "returns zero" do
        expect(volunteer.personal_project_commitment).to eq(0)
      end
    end
    context "with personal projects" do
      let(:volunteer) { FactoryGirl.build(:default_volunteer) }
      it "returns the total hours for all slots times the family size" do
        pp1 = FactoryGirl.build(:default_personal_project, duration: 2.5, volunteer_count: 20)
        pp2 = FactoryGirl.build(:default_personal_project, duration: 1.5, volunteer_count: 10)
        volunteer.personal_projects << pp1
        volunteer.personal_projects << pp2
        expect(volunteer.personal_project_commitment).to eq(65.0)
      end
    end
  end

end
