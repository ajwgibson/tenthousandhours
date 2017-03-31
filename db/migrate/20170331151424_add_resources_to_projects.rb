class AddResourcesToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :materials, :string
    add_column :projects, :adults,    :integer
    add_column :projects, :youth,     :integer
  end
end
