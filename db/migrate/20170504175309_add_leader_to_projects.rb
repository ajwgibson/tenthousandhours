class AddLeaderToProjects < ActiveRecord::Migration[5.1]
  def change
    add_column :projects, :leader, :string
  end
end
