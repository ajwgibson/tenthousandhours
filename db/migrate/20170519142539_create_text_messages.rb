class CreateTextMessages < ActiveRecord::Migration
  def change
    create_table :text_messages do |t|
      t.text       :message,     null: false
      t.text       :recipients,  null: false
      t.text       :response
      t.string     :status,      null: false
      t.timestamps null: false
    end
  end
end
