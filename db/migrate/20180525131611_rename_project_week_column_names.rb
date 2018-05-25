class RenameProjectWeekColumnNames < ActiveRecord::Migration[5.1]
  def change
    change_table :projects do |t|
      t.rename :july_3,  :week_1
      t.rename :july_10, :week_2
      t.rename :july_17, :week_3
      t.rename :july_24, :week_4
    end
  end
end
