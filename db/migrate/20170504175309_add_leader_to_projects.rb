class AddLeaderToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :leader, :string
  end
end
