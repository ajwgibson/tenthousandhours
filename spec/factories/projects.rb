FactoryGirl.define do

  factory :project do

    typeform_id           nil
    organisation_type     nil
    organisation_name     nil
    contact_name          nil
    contact_role          nil
    contact_email         nil
    contact_phone         nil
    project_1_summary     nil
    project_1_information nil
    project_1_under_18    false
    project_2_summary     nil
    project_2_information nil
    project_2_under_18    false
    project_3_summary     nil
    project_3_information nil
    project_3_under_18    false
    any_week              true
    july_3                false
    july_10               false
    july_17               false
    july_24               false
    evenings              false
    saturday              false
    notes                 nil
    submitted_at          1.days.ago.change(:sec => 0)
    adults                nil
    youth                 nil
    materials             nil
  end

  factory :default_project, parent: :project do
    organisation_type   "School"
    organisation_name   "Causeway Coast Primary"
  end

end
