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


  describe "#send_message" do
    context "if message is empty" do
      it "does not send a text message" do
        expect {
          TextLocalService.send_message('', '1234')
        }.to_not change(TextMessage, :count)
      end
    end
    context "if numbers is nil" do
      it "does not send a text message" do
        expect {
          TextLocalService.send_message('Hello world', nil)
        }.to_not change(TextMessage, :count)
      end
    end
    context "if numbers is an empty string" do
      it "does not send a text message" do
        expect {
          TextLocalService.send_message('Hello world', '')
        }.to_not change(TextMessage, :count)
      end
    end
    context "if numbers is an empty array" do
      it "does not send a text message" do
        expect {
          TextLocalService.send_message('Hello world', [])
        }.to_not change(TextMessage, :count)
      end
    end
    context "if numbers is a string" do
      let(:message) { TextMessage.first }
      def send_message
        TextLocalService.send_message('Hello world', '1234')
      end
      it "sends a text message" do
        expect {
          send_message
        }.to change(TextMessage, :count).by(1)
      end
      it "uses the message provided" do
        send_message
        expect(message.message).to eq('Hello world')
      end
      it "uses the numbers value provided" do
        send_message
        expect(message.recipients).to eq('1234')
      end
    end
    context "if numbers is an array" do
      let(:message) { TextMessage.first }
      it "concatenates the values into a comma separated string" do
        TextLocalService.send_message('Hello world', ['1234','5678'])
        expect(message.recipients).to eq('1234,5678')
      end
    end
  end

end
