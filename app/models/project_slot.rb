class ProjectSlot < ActiveRecord::Base

  acts_as_paranoid

  include Filterable

  belongs_to :project

  validates :slot_date, :presence => true
  validates :slot_type, :presence => true

  enum slot_type: [ :morning, :afternoon, :evening ]

  scope :for_week,  ->(value) { where('select extract(week from slot_date)=?', value) }
  scope :for_date,  ->(value) { where(slot_date: value) }
  scope :of_type,   ->(value) { where('slot_type = ?', ProjectSlot.slot_types[value]) }
  scope :for_children, ->(value) {
    joins("join projects on project_slots.project_id=projects.id").
    where('projects.kids > 0')
  }
  scope :for_youth, ->(value) {
    joins("join projects on project_slots.project_id=projects.id").
    where('projects.youth > 0')
  }
  scope :with_project_name, ->(value) {
    joins("join projects on project_slots.project_id=projects.id").
    where("lower(projects.project_name) like lower(?)", "%#{value}%")
  }

  def self.selectable_slot_types
    ProjectSlot.slot_types.keys.map { |t| [t.humanize, t] }
  end

  def humanized_slot_type
    slot_type.humanize
  end

end
