require 'rails_helper'

RSpec.describe Volunteer, type: :model do

  it 'has a valid factory' do
    expect(FactoryBot.build(:default_volunteer)).to be_valid
  end


  # VALIDATION

  describe "a volunteer" do
    it "is not valid without a first_name" do
      expect(FactoryBot.build(:default_volunteer, first_name: nil)).not_to be_valid
    end
    it "is not valid without a last_name" do
      expect(FactoryBot.build(:default_volunteer, last_name: nil)).not_to be_valid
    end
    it "is not valid without an mobile" do
      expect(FactoryBot.build(:default_volunteer, mobile: nil)).not_to be_valid
    end
    it "is not valid without an age_category" do
      expect(FactoryBot.build(:default_volunteer, age_category: nil)).not_to be_valid
    end
    it "is not valid without a numeric extra_adults value" do
      expect(FactoryBot.build(:default_volunteer, extra_adults: nil)).not_to be_valid
    end
    it "is not valid without a numeric extra_youth value" do
      expect(FactoryBot.build(:default_volunteer, extra_youth: nil)).not_to be_valid
    end
    it "is not valid without a numeric extra_children value" do
      expect(FactoryBot.build(:default_volunteer, extra_children: nil)).not_to be_valid
    end
    context "who is under 18" do
      it "is not valid without a guardian_name" do
        expect(FactoryBot.build(:youth_volunteer, guardian_name: nil)).not_to be_valid
      end
      it "is not valid without a guardian_contact_number" do
        expect(FactoryBot.build(:youth_volunteer, guardian_contact_number: nil)).not_to be_valid
      end
      it "is not valid with a non-zero extra_adults value" do
        expect(FactoryBot.build(:youth_volunteer, extra_adults: 1)).not_to be_valid
      end
      it "is not valid with a non-zero extra_youth value" do
        expect(FactoryBot.build(:youth_volunteer, extra_youth: 1)).not_to be_valid
      end
      it "is not valid with a non-zero extra_children value" do
        expect(FactoryBot.build(:youth_volunteer, extra_children: 1)).not_to be_valid
      end
    end
  end



  # CALLBACKS

  describe "#before_validation" do
    it "cleans up the mobile number" do
      v = FactoryBot.build(:default_volunteer, mobile: '  + 4 4 ( 0 ) 0012 3  40')
      v.valid?
      expect(v.mobile).to eq('12340')
    end
    it "handles an empty mobile number gracefully" do
      v = FactoryBot.build(:default_volunteer, mobile: nil)
      v.valid?
      expect(v.mobile).to eq(nil)
    end
  end

  describe "#before_create" do
    it "allocates a random, 4 digit mobile confirmation code" do
      v = FactoryBot.create(:default_volunteer)
      expect(v.mobile_confirmation_code).to_not eq(nil)
      expect(v.mobile_confirmation_code.length).to eq(4)
    end
  end


  # SCOPES

  describe 'scope:with_first_name' do
    it 'includes records where the first_name contains the value' do
      aaa    = FactoryBot.create(:default_volunteer, first_name: 'aaa')
      bab    = FactoryBot.create(:default_volunteer, first_name: 'bab')
      bbb    = FactoryBot.create(:default_volunteer, first_name: 'bbb')
      filtered = Volunteer.with_first_name('a')
      expect(filtered).to include(aaa)
      expect(filtered).to include(bab)
      expect(filtered).not_to include(bbb)
    end
  end

  describe 'scope:with_last_name' do
    it 'includes records where the last_name contains the value' do
      aaa    = FactoryBot.create(:default_volunteer, last_name: 'aaa')
      bab    = FactoryBot.create(:default_volunteer, last_name: 'bab')
      bbb    = FactoryBot.create(:default_volunteer, last_name: 'bbb')
      filtered = Volunteer.with_last_name('a')
      expect(filtered).to include(aaa)
      expect(filtered).to include(bab)
      expect(filtered).not_to include(bbb)
    end
  end

  describe 'scope:with_email' do
    it 'includes records where the email contains the value' do
      aaa    = FactoryBot.create(:default_volunteer, email: 'aaa@x.y')
      bab    = FactoryBot.create(:default_volunteer, email: 'bab@x.y')
      bbb    = FactoryBot.create(:default_volunteer, email: 'bbb@x.y')
      filtered = Volunteer.with_email('a')
      expect(filtered).to include(aaa)
      expect(filtered).to include(bab)
      expect(filtered).not_to include(bbb)
    end
  end

  describe 'scope:with_mobile' do
    it 'includes records where the mobile number contains the value (with spaces ignored)' do
      aaa    = FactoryBot.create(:default_volunteer, mobile: 'aaa')
      bab    = FactoryBot.create(:default_volunteer, mobile: 'bab')
      bbb    = FactoryBot.create(:default_volunteer, mobile: 'bbb')
      filtered = Volunteer.with_mobile(' a ')
      expect(filtered).to include(aaa)
      expect(filtered).to include(bab)
      expect(filtered).not_to include(bbb)
    end
  end

  describe 'scope:in_age_category' do
    it 'includes records where the volunteer age_category matches the value' do
      a = FactoryBot.create(:default_volunteer)
      b = FactoryBot.create(:youth_volunteer)
      filtered = Volunteer.in_age_category('youth')
      expect(filtered).to include(b)
      expect(filtered).not_to include(a)
    end
  end

  describe 'scope:with_skill' do
    it 'includes records where the volunteer has the specific skill' do
      a = FactoryBot.create(:default_volunteer, skills: ['a','z'])
      b = FactoryBot.create(:default_volunteer, skills: ['b','z'])
      filtered = Volunteer.with_skill('a')
      expect(filtered).to include(a)
      expect(filtered).not_to include(b)
    end
  end

  describe 'scope:without_projects' do
    it 'includes records where the volunteer has not signed up for any projects' do
      s1 = FactoryBot.create(:default_project_slot)
      v1 = FactoryBot.create(:default_volunteer, first_name: 'v1')
      v2 = FactoryBot.create(:default_volunteer, first_name: 'v2')
      s1.volunteers << v1
      filtered = Volunteer.without_projects(true)
      expect(filtered).to include(v2)
      expect(filtered).not_to include(v1)
    end
  end


  # METHODS

  describe "#humanized_age_category" do
    it "returns 'Adult - Over 18' when age_category is 'adult'" do
      v = FactoryBot.build(:default_volunteer, age_category: 'adult')
      expect(v.humanized_age_category).to eq('Adult - over 18')
    end
    it "returns 'Youth - 13 to 17' when age_category is 'youth'" do
      v = FactoryBot.build(:default_volunteer, age_category: 'youth')
      expect(v.humanized_age_category).to eq('Youth - 13 to 17')
    end
    it "returns 'Child - under 13' when age_category is 'child'" do
      v = FactoryBot.build(:default_volunteer, age_category: 'child')
      expect(v.humanized_age_category).to eq('Child - under 13')
    end
    it "returns nil when age_category is nil" do
      v = FactoryBot.build(:default_volunteer, age_category: nil)
      expect(v.humanized_age_category).to eq(nil)
    end
  end


  describe "#adults_in_family" do
    context "when the volunteer is an adult" do
      let(:volunteer) { FactoryBot.build(:default_volunteer, age_category: 'adult') }
      context "when the volunteer has no family" do
        it "returns 1" do
          expect(volunteer.adults_in_family).to eq(1)
        end
      end
      context "when the volunteer has family that includes adults" do
        it "counts the volunteer and the other adults in the family" do
          #volunteer.family = '[{"name":"a","age_category":"adult"},{"name":"b","age_category":"youth"},{"name":"c","age_category":"child"}]'
          volunteer.extra_adults = 1
          expect(volunteer.adults_in_family).to eq(2)
        end
      end
    end
    context "when the volunteer is not an adult" do
      let(:volunteer) { FactoryBot.build(:default_volunteer, age_category: 'youth') }
      it "returns 0" do
        expect(volunteer.adults_in_family).to eq(0)
      end
      # context "when the volunteer has no family" do
      #   it "returns 0" do
      #     expect(volunteer.adults_in_family).to eq(0)
      #   end
      # end
      # context "when the volunteer has family that includes adults" do
      #   it "counts the other adults in the family" do
      #     volunteer.family = '[{"name":"a","age_category":"adult"},{"name":"b","age_category":"youth"},{"name":"c","age_category":"child"}]'
      #     expect(volunteer.adults_in_family).to eq(1)
      #   end
      # end
    end
  end

  describe "#youth_in_family" do
    context "when the volunteer is a youth" do
      let(:volunteer) { FactoryBot.build(:default_volunteer, age_category: 'youth') }
      it "returns 1" do
        expect(volunteer.youth_in_family).to eq(1)
      end
      # context "when the volunteer has no family" do
      #   it "returns 1" do
      #     expect(volunteer.youth_in_family).to eq(1)
      #   end
      # end
      # context "when the volunteer has family that includes youth" do
      #   it "counts the volunteer and the other youth in the family" do
      #     volunteer.family = '[{"name":"a","age_category":"adult"},{"name":"b","age_category":"youth"},{"name":"c","age_category":"child"}]'
      #     expect(volunteer.youth_in_family).to eq(2)
      #   end
      # end
    end
    context "when the volunteer is not a youth" do
      let(:volunteer) { FactoryBot.build(:default_volunteer, age_category: 'adult') }
      context "when the volunteer has no family" do
        it "returns 0" do
          expect(volunteer.youth_in_family).to eq(0)
        end
      end
      context "when the volunteer has family that includes youth" do
        it "counts the other youth in the family" do
          #volunteer.family = '[{"name":"a","age_category":"adult"},{"name":"b","age_category":"youth"},{"name":"c","age_category":"child"}]'
          volunteer.extra_youth = 1
          expect(volunteer.youth_in_family).to eq(1)
        end
      end
    end
  end

  describe "#children_in_family" do
    let(:volunteer) {
      FactoryBot.build(
        :default_volunteer, age_category: 'adult',
        extra_children: 3,
        #family: '[{"name":"a","age_category":"child"},{"name":"b","age_category":"child"},{"name":"c","age_category":"child"}]'
      )}
    it "counts the children in the family" do
      expect(volunteer.children_in_family).to eq(3)
    end
  end

  describe "#family_size" do
    let(:volunteer) {
      FactoryBot.build(
        :default_volunteer, age_category: 'adult',
        extra_adults: 1,
        extra_youth: 1,
        extra_children: 1,
        #family: '[{"name":"a","age_category":"adult"},{"name":"b","age_category":"child"},{"name":"c","age_category":"youth"}]'
      )}
    it "counts the total number of people in the family" do
      expect(volunteer.family_size).to eq(4)
    end
  end

  describe "#commitment" do
    context "with no project slots" do
      let(:volunteer) { FactoryBot.build(:family_of_four_volunteer) }
      it "returns zero" do
        expect(volunteer.commitment).to eq(0)
      end
    end
    context "with project slots" do
      let(:project)   { FactoryBot.build(:published_project) }
      let(:volunteer) { FactoryBot.build(:family_of_four_volunteer) }
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
      let(:volunteer) { FactoryBot.build(:default_volunteer) }
      it "returns zero" do
        expect(volunteer.personal_project_commitment).to eq(0)
      end
    end
    context "with personal projects" do
      let(:volunteer) { FactoryBot.build(:default_volunteer) }
      it "returns the total hours for all slots times the family size" do
        pp1 = FactoryBot.build(:default_personal_project, duration: 2.5, volunteer_count: 20)
        pp2 = FactoryBot.build(:default_personal_project, duration: 1.5, volunteer_count: 10)
        volunteer.personal_projects << pp1
        volunteer.personal_projects << pp2
        expect(volunteer.personal_project_commitment).to eq(65.0)
      end
    end
  end


  describe "#mobile_international_format" do
    context "when the mobile number starts with 44" do
      it "returns the mobile number unaltered" do
        v = FactoryBot.build(:default_volunteer, mobile: '441234')
        expect(v.mobile_international_format).to eq('441234')
      end
    end
    context "when the mobile number starts with +44" do
      it "returns the mobile number without the +" do
        v = FactoryBot.build(:default_volunteer, mobile: '441234')
        expect(v.mobile_international_format).to eq('441234')
      end
    end

    context "when the mobile number starts with 0" do
      it "replaces the leading zero with 44" do
        v = FactoryBot.build(:default_volunteer, mobile: '01234')
        expect(v.mobile_international_format).to eq('441234')
      end
    end
    context "when the mobile number starts with neither 44, +44 or 0" do
      it "returns the mobile number prefixed with 44" do
        v = FactoryBot.build(:default_volunteer, mobile: '1234')
        expect(v.mobile_international_format).to eq('441234')
      end
    end
  end


  describe "#mobile_confirmed?" do
    context "when the mobile_confirmation_code is nil" do
      it "returns true" do
        v = FactoryBot.build(:default_volunteer, mobile_confirmation_code: nil)
        expect(v.mobile_confirmed?).to eq(true)
      end
    end
    context "when the mobile_confirmation_code is not nil" do
      it "returns false" do
        v = FactoryBot.build(:default_volunteer, mobile_confirmation_code: '1234')
        expect(v.mobile_confirmed?).to eq(false)
      end
    end
  end

end
