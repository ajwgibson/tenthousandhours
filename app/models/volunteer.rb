class Volunteer < ApplicationRecord

  include Filterable

  has_and_belongs_to_many :project_slots
  has_many :projects, -> { distinct }, through: :project_slots
  has_many :personal_projects, dependent: :destroy
  has_many :reminders, dependent: :destroy


  # Include default devise modules. Others available are:
  # :omniauthable
  # :rememberable

  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :trackable,
         :validatable,
         :lockable,
         :timeoutable,
         :confirmable

   enum age_category: [ :adult, :youth, :child ]


   validates :first_name,     :presence => true
   validates :last_name,      :presence => true
   validates :mobile,         :presence => true
   validates :age_category,   :presence => true
   validates :extra_adults,   :presence => true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
   validates :extra_youth,    :presence => true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
   validates :extra_children, :presence => true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

   validate :under_18s_need_guardian_details
   validate :under_18s_cannot_include_extra_volunteers

   scope :with_first_name, ->(value) { where("lower(first_name) like lower(?)", "%#{value}%") }
   scope :with_last_name,  ->(value) { where("lower(last_name) like lower(?)", "%#{value}%") }
   scope :with_email,      ->(value) { where("lower(email) like lower(?)", "%#{value}%") }
   scope :with_mobile,     ->(value) { where("lower(mobile) like lower(?)", "%#{value.gsub(/\s+/, '')}%") }
   scope :with_skill,      ->(value) { where("? = ANY(skills)", value) }
   scope :in_age_category, ->(value) { where age_category: age_categories[value] }
   scope :without_projects,->(value) { includes(:projects).where(projects: { id: nil }) }
   scope :needs_activity_consent,  ->(value) { in_age_category(:youth).where(activity_consent_recorded_by: nil) }
   scope :with_can_contact_future, ->(value) { where can_contact_future: value }


   before_validation(on: [:create, :update]) do
     clean_mobile!
   end


   before_create do
     self.mobile_confirmation_code = rand(1..9999).to_s.rjust(4, '0')
   end


   def self.to_csv
     attributes = %w(
       first_name last_name mobile_international_format email
       humanized_age_category family_size
       commitment personal_project_commitment
       can_contact_future
     )
     CSV.generate(headers: true) do |csv|
       csv << attributes
       all.each do |volunteer|
         csv << attributes.map{ |attr| volunteer.send(attr) }
       end
     end
   end



   def name
     return "#{first_name} #{last_name}".strip if first_name?
     email
   end

   def humanized_age_category
     human_age_category age_category
   end

   def adults_in_family
     #count = family_hash.count { |p| p['age_category'] == :adult.to_s }
     count = extra_adults
     return count+1 if adult?
     count
   end

   def youth_in_family
     #count = family_hash.count { |p| p['age_category'] == :youth.to_s }
     count = extra_youth
     return count+1 if youth?
     count
   end

   def children_in_family
     #family_hash.count { |p| p['age_category'] == :child.to_s }
     extra_children
   end

   def family_size
     adults_in_family + youth_in_family + children_in_family
   end

   def family_members
     family_hash.map do |p|
       { 'name' => p['name'], 'age_category' => human_age_category(p['age_category']) }
     end
   end

   def commitment
     project_slots.inject(0) { |sum,slot| sum + slot.slot_length } * family_size
   end

   def personal_project_commitment
     personal_projects.inject(0) { |sum,p| sum + p.commitment }
   end

   def mobile_confirmed?
     mobile_confirmation_code.blank?
   end

   def mobile_international_format
     "44#{clean_mobile(mobile)}"
   end

   def mobile_local_format
     "0#{clean_mobile(mobile)}"
   end

   def activity_consent_required?
     return true if youth? && activity_consent_recorded_by.blank?
     false
   end



private

   def family_hash
     return JSON.parse family unless family.blank?
     {}
   end


   def human_age_category(category)
     return nil if category.nil?
     description = category.eql?(:adult.to_s) ? 'over 18' :
        category.eql?(:youth.to_s) ? '13 to 17' : 'under 13'
     "#{category.humanize} - #{description}"
   end


   def clean_mobile!
     if attribute_present?("mobile")
       self.mobile = clean_mobile(self.mobile)
     end
   end

   def clean_mobile(mobile)
     mobile.gsub!(/\s+/,       '')
     mobile.sub!(/^(\+)?(44)/, '')
     mobile.gsub!(/[\(,\)]/,   '')
     mobile.sub!(/^(0)+/,      '')
     mobile
   end


   def under_18s_need_guardian_details
     if youth?
       errors.add(:guardian_name, "is required for an under 18 volunteer") if guardian_name.blank?
       errors.add(:guardian_contact_number, "is required for an under 18 volunteer") if guardian_contact_number.blank?
     end
   end


   def under_18s_cannot_include_extra_volunteers
     if youth?
       errors.add(:extra_adults,   "must be zero for an under 18 volunteer") if extra_adults > 0
       errors.add(:extra_youth,    "must be zero for an under 18 volunteer") if extra_youth > 0
       errors.add(:extra_children, "must be zero for an under 18 volunteer") if extra_children > 0
     end
   end

end
