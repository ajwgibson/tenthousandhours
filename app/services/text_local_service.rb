require "net/https"
require "uri"
require "json"


class TextLocalService

  URL    = 'http://api.txtlocal.com/send/?'
  SENDER = '10,000 hours'


  def self.send_confirmation(volunteer)
    unless volunteer.mobile.blank? || volunteer.mobile_confirmation_code.blank?
      message =
        "Hi #{volunteer.first_name}, your SMS confirmation code is #{volunteer.mobile_confirmation_code}."
      send_message(message, volunteer.mobile_international_format)
    end
  end


  def self.send_message(message, numbers)

    return if message.blank?
    return if numbers.blank?

    numbers = numbers.join(',') if numbers.kind_of?(Array)

    tm = TextMessage.new
    tm.message    = message
    tm.recipients = numbers
    tm.status     = 'test'

    unless Rails.configuration.x.text_local_service.test

      uri     = URI.parse(URL)
      http    = Net::HTTP.start(uri.host, uri.port)
      request = Net::HTTP::Get.new(uri.request_uri)

      tm.response = Net::HTTP.post_form(
        uri,
        'apiKey'  => Rails.configuration.x.text_local_service.api_key,
        'message' => message,
        'sender'  => SENDER,
        'numbers' => numbers
      ).body

      tm.status = JSON.parse(tm.response)['status']

    end

    tm.save!
  end

end
