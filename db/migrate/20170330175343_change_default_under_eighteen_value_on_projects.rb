class ChangeDefaultUnderEighteenValueOnProjects < ActiveRecord::Migration[5.1]
  def up
    change_column_default :projects, :project_3_under_18, nil
  end
  def down
    # Don't rollback to previous behehaviour as it was always wrong!
    change_column_default :projects, :project_3_under_18, nil
  end
end
