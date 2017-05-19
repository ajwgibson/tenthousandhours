require 'rails_helper'

RSpec.describe TextLocalService do

  describe "#send_confirmation" do

    context "for a volunteer with an unconfirmed mobile number" do

      let(:volunteer) {
        FactoryGirl.build(
          :default_volunteer,
          first_name: 'Bob',
          mobile: '1234567890',
          mobile_confirmation_code: '1111'
        )
      }

      let(:message)   { TextMessage.first }

      def send_confirmation
        TextLocalService.send_confirmation volunteer
      end

      it "sends a text message" do
        expect {
          send_confirmation
        }.to change(TextMessage, :count).by(1)
      end

      it "sends the message using an international number format" do
        send_confirmation
        expect(message.recipients).to eq('441234567890')
      end

      it "includes the confirmation code in the message" do
        send_confirmation
        expect(message.message).to include('1111')
      end

      it "includes the volunteer's first name in the message" do
        send_confirmation
        expect(message.message).to include('Bob')
      end
      
    end

    context "for a volunteer with no mobile number" do
      let(:volunteer) { FactoryGirl.build(:default_volunteer, mobile: nil ) }
      it "does not send a text message" do
        expect {
          TextLocalService.send_confirmation volunteer
        }.to_not change(TextMessage, :count)
      end
    end

    context "for a volunteer with a confirmed mobile number" do
      let(:volunteer) { FactoryGirl.build(:default_volunteer, mobile_confirmation_code: nil ) }
      it "does not send a text message" do
        expect {
          TextLocalService.send_confirmation volunteer
        }.to_not change(TextMessage, :count)
      end
    end

  end

end
