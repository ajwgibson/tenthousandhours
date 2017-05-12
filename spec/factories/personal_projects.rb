FactoryGirl.define do

  factory :personal_project do
  end

  factory :default_personal_project, parent: :personal_project do
    project_date    10.days.from_now
    duration        2.5
    volunteer_count 12
    description     'Some kind of tidy-up in my area'
    association     :volunteer, factory: :default_volunteer
  end

end
