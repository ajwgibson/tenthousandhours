FactoryGirl.define do

  factory :project_slot do
  end

  factory :default_project_slot, parent: :project_slot do
    slot_type  :evening
    slot_date  10.days.from_now
    association :project, factory: :default_project
  end

end
