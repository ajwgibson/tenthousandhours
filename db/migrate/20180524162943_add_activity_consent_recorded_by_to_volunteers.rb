class AddActivityConsentRecordedByToVolunteers < ActiveRecord::Migration[5.1]
  def change
    add_column :volunteers, :activity_consent_recorded_by, :string
  end
end
