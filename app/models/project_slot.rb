class ProjectSlot < ActiveRecord::Base

  acts_as_paranoid

  belongs_to :project

  validates :slot_date, :presence => true
  validates :slot_type, :presence => true

  enum slot_type: [ :morning, :afternoon, :evening ]

  def self.selectable_slot_types
    ProjectSlot.slot_types.keys.map { |t| [t.humanize, t] }
  end

  def humanized_slot_type
    slot_type.humanize
  end

end
