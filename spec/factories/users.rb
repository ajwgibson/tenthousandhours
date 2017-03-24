require 'faker'

FactoryGirl.define do
  factory :user do
    email       nil
    password    nil
  end
  factory :default_user, parent: :user do
    email       Faker::Internet.email
    password    "password"
  end
end
