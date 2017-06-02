require 'rails_helper'

RSpec.describe ManualSignUp, type: :model do

  # VALIDATION
  context "validation" do
    it "is not valid without slot_id" do
      m = ManualSignUp.new
      expect(m).not_to be_valid
    end
  end

end
