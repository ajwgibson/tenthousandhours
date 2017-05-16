class SetDefaultProjectHours < ActiveRecord::Migration

  def self.up
    change_column_default :projects, :morning_start_time,    '09:30'
    change_column_default :projects, :afternoon_start_time,  '14:00'
    change_column_default :projects, :evening_start_time,    '19:00'
    change_column_default :projects, :morning_slot_length,   3
    change_column_default :projects, :afternoon_slot_length, 3.5
    change_column_default :projects, :evening_slot_length,   3

    say_with_time "Updating project slot times..." do
      Project.all.each do |p|
        p.update_attribute :morning_start_time,   '09:30'
        p.update_attribute :afternoon_start_time, '14:00'
        p.update_attribute :evening_start_time,   '19:00'
        p.update_attribute :morning_slot_length,   3
        p.update_attribute :afternoon_slot_length, 3.5
        p.update_attribute :evening_slot_length,   3
      end
    end
  end

  def self.down
  end

end
