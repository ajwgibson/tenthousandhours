require 'rails_helper'

RSpec.describe ComposeMessage, type: :model do

  # VALIDATION
  context "validation" do
    it "is not valid without message_text" do
      m = ComposeMessage.new
      expect(m).not_to be_valid
    end
  end

end
