class CreateReminders < ActiveRecord::Migration[5.1]
  def change
    create_table :reminders do |t|
      t.references :project,       null: false, index:true, foreign_key: true
      t.references :volunteer,     null: false, index:true, foreign_key: true
      t.date       :reminder_date, null: false
      t.timestamps null: false
    end
  end
end
