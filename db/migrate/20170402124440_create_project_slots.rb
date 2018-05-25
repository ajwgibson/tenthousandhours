class CreateProjectSlots < ActiveRecord::Migration[5.1]
  def change
    create_table :project_slots do |t|
      t.date       :slot_date, null: false
      t.integer    :slot_type, null: false
      t.references :project,   null: false, index:true, foreign_key: true
      t.timestamps null: false
      t.datetime   :deleted_at
    end
    add_index :project_slots, :deleted_at
  end
end
