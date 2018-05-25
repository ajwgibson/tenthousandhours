class AddTimesToProjects < ActiveRecord::Migration[5.1]
  def change
    add_column :projects, :morning_start_time,   :string
    add_column :projects, :afternoon_start_time, :string
    add_column :projects, :evening_start_time,   :string
  end
end
