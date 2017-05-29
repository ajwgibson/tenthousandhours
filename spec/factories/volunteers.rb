FactoryGirl.define do

  factory :volunteer do
    email                   nil
    password                nil
    password_confirmation   nil
    first_name              nil
    last_name               nil
    mobile                  nil
    age_category            nil
    skills                  nil
    family                  nil
    guardian_name           nil
    guardian_contact_number nil
  end

  factory :default_volunteer, parent: :volunteer do
    email                 { Faker::Internet.email }
    password              "password"
    password_confirmation "password"
    first_name            { Faker::Name.first_name }
    last_name             { Faker::Name.last_name }
    mobile                { Faker::PhoneNumber.cell_phone }
    age_category          :adult
    skills                []
  end

  factory :youth_volunteer, parent: :default_volunteer do
    age_category            :youth
    guardian_name           { Faker::Name.name }
    guardian_contact_number { Faker::PhoneNumber.phone_number }
  end

  factory :family_of_four_volunteer, parent: :default_volunteer do
    family  '[{"name":"Dad","age_category":"adult"},{"name":"Youth","age_category":"youth"},{"name":"Child","age_category":"child"}]'
  end

  factory :family_of_five_volunteer, parent: :default_volunteer do
    family  '[{"name":"Dad","age_category":"adult"},{"name":"Youth","age_category":"youth"},{"name":"Child1","age_category":"child"},{"name":"Child2","age_category":"child"}]'
  end

end
