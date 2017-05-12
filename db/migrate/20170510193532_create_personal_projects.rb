class CreatePersonalProjects < ActiveRecord::Migration
  def change
    create_table :personal_projects do |t|
      t.date       :project_date, null: false
      t.decimal    :duration, null: false, precision: 2, scale: 1
      t.integer    :volunteer_count, null: false
      t.text       :description, null: false
      t.references :volunteer, null: false, index:true, foreign_key: true
      t.timestamps null: false
      t.datetime   :deleted_at
    end
    add_index :personal_projects, :deleted_at
  end
end
