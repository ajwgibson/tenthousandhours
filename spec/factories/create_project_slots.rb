FactoryGirl.define do

  factory :create_project_slot do
  end

  factory :default_create_project_slot, parent: :create_project_slot do
    start_date     10.days.from_now.to_s
    end_date       12.days.from_now.to_s
    morning_slot   '1'
    afternoon_slot '1'
    evening_slot   '1'
  end

end
