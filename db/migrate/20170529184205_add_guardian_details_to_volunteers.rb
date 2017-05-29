class AddGuardianDetailsToVolunteers < ActiveRecord::Migration
  def change
    add_column :volunteers, :guardian_name,           :string
    add_column :volunteers, :guardian_contact_number, :string
  end
end
