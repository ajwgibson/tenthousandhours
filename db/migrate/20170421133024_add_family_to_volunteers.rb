class AddFamilyToVolunteers < ActiveRecord::Migration[5.1]
  def change
    add_column :volunteers, :family, :text
  end
end
