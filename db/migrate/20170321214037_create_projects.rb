class CreateProjects < ActiveRecord::Migration[5.1]
  def change
    create_table :projects do |t|

      t.string  :typeform_id

      t.string  :organisation_type,  null: false
      t.string  :organisation_name,  null: false

      t.string  :contact_name
      t.string  :contact_role
      t.string  :contact_email
      t.string  :contact_phone

      t.string  :project_1_summary
      t.string  :project_1_information
      t.boolean :project_1_under_18

      t.string  :project_2_summary
      t.string  :project_2_information
      t.boolean :project_2_under_18

      t.string  :project_3_summary
      t.string  :project_3_information
      t.boolean :project_3_under_18,  default: false

      t.boolean :any_week,            default: true

      t.boolean :july_3,              default: false
      t.boolean :july_10,             default: false
      t.boolean :july_17,             default: false
      t.boolean :july_24,             default: false

      t.boolean :evenings,  default: false
      t.boolean :saturday,  default: false

      t.string :notes

      t.datetime   :submitted_at
      t.timestamps null: false
      t.datetime   :deleted_at
    end

    add_index :projects, :deleted_at

  end
end
