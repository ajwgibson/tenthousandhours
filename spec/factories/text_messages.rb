FactoryGirl.define do

  factory :text_message do
    message     nil
    recipients  nil
    response    nil
    status      nil
  end

  factory :default_text_message, parent: :text_message do
    message     Faker::Lorem.sentence
    recipients  Faker::PhoneNumber.cell_phone
    response    '{ status: success }'
    status      'success'
  end

end
