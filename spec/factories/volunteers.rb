FactoryGirl.define do

  factory :volunteer do
    email                 nil
    password              nil
    password_confirmation nil
    first_name            nil
    last_name             nil
    mobile                nil
    age_category          nil
    skills                nil
  end

  factory :default_volunteer, parent: :volunteer do
    email                 { Faker::Internet.email }
    password              "password"
    password_confirmation "password"
    first_name            Faker::Name.first_name
    last_name             Faker::Name.last_name
    mobile                Faker::PhoneNumber.cell_phone
    age_category          :adult
  end

end
