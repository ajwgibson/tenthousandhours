class SplitYouthAndKidsCounts < ActiveRecord::Migration
  def change
    add_column :projects, :kids, :integer
  end
end
