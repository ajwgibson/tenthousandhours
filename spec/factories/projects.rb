FactoryGirl.define do

  factory :project do

    typeform_id            nil
    organisation_type      nil
    project_name           nil
    contact_name           nil
    contact_role           nil
    contact_email          nil
    contact_phone          nil
    activity_1_summary     nil
    activity_1_information nil
    activity_1_under_18    false
    activity_2_summary     nil
    activity_2_information nil
    activity_2_under_18    false
    activity_3_summary     nil
    activity_3_information nil
    activity_3_under_18    false
    any_week               true
    july_3                 false
    july_10                false
    july_17                false
    july_24                false
    evenings               false
    saturday               false
    notes                  nil
    submitted_at           1.days.ago.change(:sec => 0)
    adults                 nil
    youth                  nil
    materials              nil
  end

  factory :default_project, parent: :project do
    status              :draft
    organisation_type   "School"
    project_name        "Causeway Coast Primary"
  end

  factory :good_to_publish_project, parent: :default_project do
    status              :draft
    organisation_type   "School"
    project_name        "Causeway Coast Primary"
    adults              10
    summary             'Some kind of summary'

    after(:create) do |project|
      create(:default_project_slot, project: project)
    end
  end

  factory :published_project, parent: :default_project do
    status              :published
  end

end
