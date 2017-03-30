require 'faker'

FactoryGirl.define do
  factory :user do
    email                 nil
    password              nil
    password_confirmation nil
    first_name            nil
    last_name             nil
    role                  nil
  end
  factory :default_user, parent: :user do
    email                 { Faker::Internet.email }
    password              "password"
    password_confirmation "password"
    first_name            Faker::Name.first_name
    last_name             Faker::Name.last_name
    role                  User::ROLES[0]
  end
end
