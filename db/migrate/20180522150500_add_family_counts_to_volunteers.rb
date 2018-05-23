class AddFamilyCountsToVolunteers < ActiveRecord::Migration[5.1]
  def change
    add_column :volunteers, :extra_adults,   :integer, null: false, default: 0
    add_column :volunteers, :extra_youth,    :integer, null: false, default: 0
    add_column :volunteers, :extra_children, :integer, null: false, default: 0
  end
end
