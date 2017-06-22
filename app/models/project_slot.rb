class ProjectSlot < ActiveRecord::Base

  acts_as_paranoid

  include Filterable

  belongs_to :project
  has_and_belongs_to_many :volunteers

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


  def start_time
    return project.morning_start_time   ||= 'tbc' if morning?
    return project.afternoon_start_time ||= 'tbc' if afternoon?
    return project.evening_start_time   ||= 'tbc' if evening?
    'tbc'
  end


  def slot_length
    return project.morning_slot_length   ||= 0 if morning?
    return project.afternoon_slot_length ||= 0 if afternoon?
    return project.evening_slot_length   ||= 0 if evening?
  end


  def end_time
    return 'tbc' if (start_time == 'tbc') || (slot_length == 0)
    (Time.parse(start_time) + (slot_length*60*60)).strftime("%H:%M")
  end


  def volunteer_count
    volunteers.inject(0) { |sum,v| sum + v.family_size }
  end

  def adults
    volunteers.inject(0) { |sum,v| sum + v.adults_in_family }
  end

  def youth
    volunteers.inject(0) { |sum,v| sum + v.youth_in_family }
  end

  def children
    volunteers.inject(0) { |sum,v| sum + v.children_in_family }
  end

  def adult_cover
    return 0 if project.adults.nil?
    ((adults.to_f / project.adults) * 100).floor
  end


  def can_sign_up?(volunteer)

    youth_limit = project.youth ||= 0
    adult_limit = project.adults ||= 0

    if volunteer.youth?
      return false unless project.suitable_for_youth?
      return false if youth >= youth_limit
      return true
    end

    return false if adults >= adult_limit

    true
  end


end
