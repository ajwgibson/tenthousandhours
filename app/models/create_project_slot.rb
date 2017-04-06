class CreateProjectSlot
  include ActiveModel::Model

  attr_accessor :start_date, :end_date,
                :morning_slot, :afternoon_slot, :evening_slot

  validates :start_date, :presence => true

  validate :check_dates,
           :at_least_one_slot_type


  def morning_slot?
    is_set @morning_slot
  end

  def afternoon_slot?
    is_set @afternoon_slot
  end

  def evening_slot?
    is_set @evening_slot
  end


  def create_slots(project)
    total = 0
    range = ( Date.parse(@start_date) .. Date.parse(@start_date))
    range = ( Date.parse(@start_date) .. Date.parse(@end_date)) unless @end_date.blank?
    range.each do |r|
      total += create_slot(:morning, project, r)   if morning_slot?
      total += create_slot(:afternoon, project, r) if afternoon_slot?
      total += create_slot(:evening, project, r)   if evening_slot?
    end
    total
  end


  private

    def create_slot(slot_type, project, date)

      # Don't create a duplicate!
      return 0 if ProjectSlot.exists?(
                    project_id: project.id,
                    slot_type: ProjectSlot.slot_types[slot_type],
                    slot_date: date)

      slot = ProjectSlot.new
      slot.slot_date = date
      slot.slot_type = slot_type
      slot.project = project
      slot.save
      return 1
    end

    def at_least_one_slot_type
      errors.add(:base, "You must select at least one of the slot types") unless morning_slot? || afternoon_slot? || evening_slot?
    end

    def is_set value
      '1' == value
    end

    def check_dates
      start_date_value = Date.parse start_date rescue nil
      end_date_value   = Date.parse end_date   rescue nil
      errors.add(:start_date, "must be a valid date") if start_date_value.nil?
      errors.add(:end_date, "must be a valid date") if end_date_value.nil? && !end_date.blank?
      errors.add(:end_date, "must be after the start date") if !end_date_value.nil? && !start_date_value.nil? && end_date_value < start_date_value
    end

end
