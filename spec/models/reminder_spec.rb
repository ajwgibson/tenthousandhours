require 'rails_helper'

RSpec.describe Reminder, type: :model do

  it 'has a valid factory' do
    expect(FactoryGirl.build(:default_reminder)).to be_valid
  end

  it "is not valid without a reminder_date" do
    expect(FactoryGirl.build(:default_reminder, reminder_date: nil)).not_to be_valid
  end

end
