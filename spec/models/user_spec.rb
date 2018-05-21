require 'rails_helper'

RSpec.describe User, type: :model do

  it 'has a valid factory' do
    expect(FactoryBot.build(:default_user)).to be_valid
  end

  # VALIDATION

  it "is invalid without a first_name" do
    expect(FactoryBot.build(:default_user, first_name: nil)).not_to be_valid
  end
  it "is invalid without a last_name" do
    expect(FactoryBot.build(:default_user, last_name: nil)).not_to be_valid
  end
  it "is invalid without an email" do
    expect(FactoryBot.build(:default_user, email: nil)).not_to be_valid
  end
  it "is invalid without a role" do
    expect(FactoryBot.build(:default_user, role: nil)).not_to be_valid
  end
  it "is invalid without a password_confirmation" do
    expect(FactoryBot.build(:default_user, password_confirmation: nil)).not_to be_valid
  end
  it "is invalid without a matching password and password_confirmation" do
    expect(FactoryBot.build(:default_user,
                             password: 'aaaaaaaa',
                             password_confirmation: 'bbbbbbbb')).not_to be_valid
  end


  # ROLES

  it "is an organiser when role is 'Organiser'" do
    expect(FactoryBot.build(:default_user, role: :Organiser).organiser?).to be_truthy
  end
  it "is not an organiser when role is 'organiser'" do
    expect(FactoryBot.build(:default_user, role: 'organiser').organiser?).to be_falsey
  end
  it "is not an organiser when role is nil" do
    expect(FactoryBot.build(:default_user, role: nil).organiser?).to be_falsey
  end

  it "is an overseer when role is 'Overseer'" do
    expect(FactoryBot.build(:default_user, role: :Overseer).overseer?).to be_truthy
  end
  it "is not an overseer when role is 'overseer'" do
    expect(FactoryBot.build(:default_user, role: 'overseer').overseer?).to be_falsey
  end
  it "is not an overseer when role is nil" do
    expect(FactoryBot.build(:default_user, role: nil).overseer?).to be_falsey
  end

  it "is a coordinator when role is 'Coordinator'" do
    expect(FactoryBot.build(:default_user, role: :Coordinator).coordinator?).to be_truthy
  end
  it "is not a coordinator when role is 'coordinator'" do
    expect(FactoryBot.build(:default_user, role: 'coordinator').coordinator?).to be_falsey
  end
  it "is not a coordinator when role is nil" do
    expect(FactoryBot.build(:default_user, role: nil).coordinator?).to be_falsey
  end

  it "is a leader when role is 'Leader'" do
    expect(FactoryBot.build(:default_user, role: :Leader).leader?).to be_truthy
  end
  it "is not a leader when role is 'leader'" do
    expect(FactoryBot.build(:default_user, role: 'leader').leader?).to be_falsey
  end
  it "is not a leader when role is nil" do
    expect(FactoryBot.build(:default_user, role: nil).leader?).to be_falsey
  end


  # name

  describe '#name' do
    it "is 'John Smith' when first_name is 'John' and last_name is 'Smith'" do
      expect(FactoryBot.build(:default_user, first_name: 'John', last_name: 'Smith').name).to eq('John Smith')
    end
    it "is 'John' when first_name is 'John' and last_name is nil" do
      expect(FactoryBot.build(:default_user, first_name: 'John', last_name: nil).name).to eq('John')
    end
    it "is 'Smith' when first_name is nil and last_name is 'Smith'" do
      expect(FactoryBot.build(:default_user, first_name: nil, last_name: 'Smith').name).to eq('Smith')
    end
  end


end
