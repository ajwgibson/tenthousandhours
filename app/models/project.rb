require 'csv'

class Project < ApplicationRecord

  acts_as_paranoid
  include Filterable

  enum status: [ :draft, :published ]

  has_many :project_slots, dependent: :destroy
  has_many :volunteers, -> { distinct }, through: :project_slots
  has_many :reminders, dependent: :destroy

  validates :organisation_type, :presence => true
  validates :project_name, :presence => true
  validates :adults, numericality: { only_integer: true, allow_nil: true, greater_than_or_equal_to: 2 }
  validates :youth,  numericality: { only_integer: true, allow_nil: true, greater_than_or_equal_to: 0 }
  validates :kids,   numericality: { only_integer: true, allow_nil: true, greater_than_or_equal_to: 0 }
  validates :morning_start_time,    allow_blank: true, format: { with: /\A([01]?[0-9]|2[0-3])\:[0-5][0-9]\z/ }
  validates :afternoon_start_time,  allow_blank: true, format: { with: /\A([01]?[0-9]|2[0-3])\:[0-5][0-9]\z/ }
  validates :evening_start_time,    allow_blank: true, format: { with: /\A([01]?[0-9]|2[0-3])\:[0-5][0-9]\z/ }
  validates :morning_slot_length,   numericality: { allow_nil: true, greater_than_or_equal_to: 0.5, less_than_or_equal_to: 5.0 }
  validates :afternoon_slot_length, numericality: { allow_nil: true, greater_than_or_equal_to: 0.5, less_than_or_equal_to: 5.0 }
  validates :evening_slot_length,   numericality: { allow_nil: true, greater_than_or_equal_to: 0.5, less_than_or_equal_to: 5.0 }

  validate :under_18s_need_suitable_activities

  scope :could_run_week_1,   ->(value) { where('week_1=? OR any_week=?', true, true) }
  scope :could_run_week_2,   ->(value) { where('week_2=? OR any_week=?', true, true) }
  scope :could_run_week_3,   ->(value) { where('week_3=? OR any_week=?', true, true) }
  scope :could_run_week_4,   ->(value) { where('week_4=? OR any_week=?', true, true) }
  scope :could_run_evenings, ->(value) { where evenings: true }
  scope :could_run_saturday, ->(value) { where saturday: true }
  scope :with_name,   ->(value) { where("lower(project_name) like lower(?)", "%#{value}%") }
  scope :of_type,     ->(value) { where organisation_type: value }
  scope :with_status, ->(value) { where status: value }

  ORG_TYPES = [
    "N/A",
    "Agency/Charity",
    "Business",
    "Community",
    "Pre-school",
    "Residential centre",
    "School",
  ]

  SKILLS = [
    "Artist",
    "Builder",
    "Carpenter",
    "Catering",
    "Cleaner",
    "Electrician",
    "Gardener",
    "General handy skills",
    "Graphic design",
    "Painter",
    "Photographer",
    "Plumber",
    "Videographer",

    "Nothing specific"
  ]


  def start_date
    project_slots.order(:slot_date).first.slot_date unless project_slots.empty?
  end


  def end_date
    project_slots.order(:slot_date).last.slot_date unless project_slots.empty?
  end


  def suitable_for_youth?
    return false if youth.nil? || youth == 0
    return true
  end


  def suitable_for_kids?
    return false if kids.nil? || kids == 0
    return true
  end


  def can_publish?
    return false if project_slots.size == 0
    return false if needs_morning_start_time?   && (morning_start_time.blank? || morning_slot_length.nil?)
    return false if needs_afternoon_start_time? && (afternoon_start_time.blank? || afternoon_slot_length.nil?)
    return false if needs_evening_start_time?   && (evening_start_time.blank? || evening_slot_length.nil?)
    return false if summary.blank?
    return false if adults.nil?
    return false if leader.blank?
    true
  end


  def needs_morning_start_time?
    has_slots_of_type? 'morning'
  end


  def needs_afternoon_start_time?
    has_slots_of_type? 'afternoon'
  end


  def needs_evening_start_time?
    has_slots_of_type? 'evening'
  end


  def self.import(file)

    data = CSV.read(file, headers: :first_row, return_headers: true)

    raise 'Invalid format' if !data.headers.eql?(self.headers)

    ActiveRecord::Base.transaction do

      data.each_with_index do |row, i|

        next if i.zero?

        params = {}
        params['typeform_id']       = row[0]
        params['organisation_type'] = self.organisation_type row
        params['project_name']      = self.project_name row
        contact_offset = (row[7].eql? '1') ? 0 : 4
        params['contact_name']           = row[8  + contact_offset]
        params['contact_role']           = row[9  + contact_offset]
        params['contact_email']          = row[10 + contact_offset]
        params['contact_phone']          = row[11 + contact_offset]
        params['activity_1_summary']     = row[16]
        params['activity_1_information'] = row[17]
        params['activity_1_under_18']    = row[18].eql? '1'
        params['activity_2_summary']     = row[19]
        params['activity_2_information'] = row[20]
        params['activity_2_under_18']    = row[21].eql? '1'
        params['activity_3_summary']     = row[22]
        params['activity_3_information'] = row[23]
        params['activity_3_under_18']    = row[24].eql? '1'
        params['any_week']               = self.any_week row
        params['week_1']                 = !row[25].blank? && !params['any_week']
        params['week_2']                 = !row[26].blank? && !params['any_week']
        params['week_3']                 = !row[27].blank? && !params['any_week']
        params['week_4']                 = !row[28].blank? && !params['any_week']
        params['evenings']               = row[30].eql? '1'
        params['saturday']               = row[31].eql? '1'
        params['notes']                  = row[32]
        params['submitted_at']           = self.parse_submitted_at row[34]

        unless params['contact_phone'].blank? ||
               params['contact_phone'].start_with?('0') then
          params['contact_phone'] = "0#{params['contact_phone']}"
        end

        begin
          Project.create! params unless Project.exists?(typeform_id: params['typeform_id'])
        rescue
          raise 'Invalid data'
        end
      end
    end
  end


private

  def under_18s_need_suitable_activities
    if !youth.nil? && youth > 0 && !activity_1_under_18 && !activity_2_under_18 && !activity_3_under_18
      errors.add(:youth, "can't be more than zero when none of the projects are suitable for under 18s")
    end
    if !kids.nil? && kids > 0 && !activity_1_under_18 && !activity_2_under_18 && !activity_3_under_18
      errors.add(:kids, "can't be more than zero when none of the projects are suitable for under 18s")
    end
  end


  def has_slots_of_type?(slot_type)
    project_slots.pluck('slot_type').include? slot_type
  end


  def self.organisation_type(row)
    row[1] || ''
  end


  def self.project_name(row)
    org_type = self.organisation_type(row).downcase
    return row[6] if org_type.eql? 'residential centre'
    return row[5] if org_type.eql? 'business'
    return row[4] if org_type.eql? 'agency/charity'
    return row[3] if org_type.eql? 'school'
    row[2]
  end


  def self.parse_submitted_at(submitted_at)
    if !submitted_at.blank?
      begin
        return DateTime.strptime(submitted_at, '%m/%d/%Y %H:%M')
      rescue ArgumentError
      end
    end
    return nil
  end


  def self.any_week(row)
    !row[29].blank?
  end


  def self.headers
    [
      "#",
      "Please choose the option that best describes your organisation?",
      "Great. What is the name of your pre-school?",
      "Great. What is the name of your school?",
      "Great. What is the name of your Agency/Charity?",
      "Great. What is the name of your Business?",
      "Great. What is the name of your Residential centre?",
      "Will you be the main contact throughout the project?",
      "Great. What is your name?",
      "What is your role within the organisation?",
      "And the best email address to contact you on is?",
      "What would be the best phone number to reach you on?",
      "No problem, who will the contact person be?",
      "What is their role within the organisation?",
      "And the best email address to contact them on is?",
      "What would be the best phone number to reach them on?",
      "Thank you. What is the first of the three projects you would love 10000 hours to complete?",
      "Please include any information you feel would be helpful for us to know at this point about that project.",
      "Is this a job that would be suitable for Under 18's",
      "What is the second project you would love 10000 hours to complete?",
      "Please include any information you feel would be helpful for us to know at this point about that project.",
      "Is this a job that would be suitable for Under 18's",
      "Nearly there! What is the third project you would love 10000 hours to complete?",
      "Please include any information you feel would be helpful for us to know at this point about that project.",
      "Is this a job that would be suitable for Under 18's",
      "3rd - 7th July",
      "10th - 11th July",
      "17th - 21st July",
      "24th - 28th July",
      "No preference",
      "Would there be the option of carrying out the projects in the evenings?",
      "And what about the option of the projects being on a Saturday?",
      "Are there are any additional notes you would like to add or questions you would like to ask, please do so below.",
      "Start Date (UTC)",
      "Submit Date (UTC)",
      "Network ID"
    ]
 end

end
