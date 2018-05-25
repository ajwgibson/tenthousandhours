class AddSummaryAndStatusToProjects < ActiveRecord::Migration[5.1]
  def change
    add_column :projects, :status,  :integer, null: false, default: 0
    add_column :projects, :summary, :string
  end
end
