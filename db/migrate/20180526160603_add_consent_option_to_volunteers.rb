class AddConsentOptionToVolunteers < ActiveRecord::Migration[5.1]
  def change
    add_column :volunteers, :can_contact_future, :boolean, default: false
  end
end
