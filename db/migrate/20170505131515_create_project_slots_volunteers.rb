class CreateProjectSlotsVolunteers < ActiveRecord::Migration
  def change
    create_table :project_slots_volunteers, id: false do |t|
      t.belongs_to :project_slot, index: true
      t.belongs_to :volunteer,    index: true
    end
  end
end
