class ChangeProjectColumnNames < ActiveRecord::Migration
  def change
    change_table :projects do |t|
      t.rename :organisation_name,     :project_name
      t.rename :project_1_summary,     :activity_1_summary
      t.rename :project_1_information, :activity_1_information
      t.rename :project_1_under_18,    :activity_1_under_18
      t.rename :project_2_summary,     :activity_2_summary
      t.rename :project_2_information, :activity_2_information
      t.rename :project_2_under_18,    :activity_2_under_18
      t.rename :project_3_summary,     :activity_3_summary
      t.rename :project_3_information, :activity_3_information
      t.rename :project_3_under_18,    :activity_3_under_18
    end
  end
end
