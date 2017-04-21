class AddFamilyToVolunteers < ActiveRecord::Migration
  def change
    add_column :volunteers, :family, :text
  end
end
