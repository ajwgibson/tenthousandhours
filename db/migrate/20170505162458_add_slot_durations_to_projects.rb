class AddSlotDurationsToProjects < ActiveRecord::Migration[5.1]
  def change
    add_column :projects, :morning_slot_length,   :decimal, precision: 2, scale: 1
    add_column :projects, :afternoon_slot_length, :decimal, precision: 2, scale: 1
    add_column :projects, :evening_slot_length,   :decimal, precision: 2, scale: 1
  end
end
