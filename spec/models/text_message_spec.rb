require 'rails_helper'

RSpec.describe TextMessage, type: :model do

  it 'has a valid factory' do
    expect(FactoryBot.build(:default_text_message)).to be_valid
  end


  # SCOPES

  describe 'scope:with_recipient' do
    it 'includes records where the recipients contains the value' do
      aaa    = FactoryBot.create(:default_text_message, recipients: 'aaa')
      bab    = FactoryBot.create(:default_text_message, recipients: 'bab')
      bbb    = FactoryBot.create(:default_text_message, recipients: 'bbb')
      filtered = TextMessage.with_recipient('a')
      expect(filtered).to include(aaa)
      expect(filtered).to include(bab)
      expect(filtered).not_to include(bbb)
    end
  end

end
