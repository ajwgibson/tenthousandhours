FactoryBot.define do

  factory :reminder do
  end

  factory :default_reminder, parent: :reminder do
    reminder_date 1.day.from_now
    association :project,   factory: :default_project
    association :volunteer, factory: :default_volunteer
  end

end
