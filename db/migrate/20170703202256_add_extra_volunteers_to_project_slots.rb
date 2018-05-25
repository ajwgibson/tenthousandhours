class AddExtraVolunteersToProjectSlots < ActiveRecord::Migration[5.1]
  def change
    add_column :project_slots, :extra_volunteers, :integer, null: false, default: 0
  end
end
