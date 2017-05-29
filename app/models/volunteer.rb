class Volunteer < ActiveRecord::Base

  include Filterable

  has_and_belongs_to_many :project_slots
  has_many :projects, -> { distinct }, through: :project_slots
  has_many :personal_projects, dependent: :destroy


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

   validates :first_name,   :presence => true
   validates :last_name,    :presence => true
   validates :mobile,       :presence => true
   validates :age_category, :presence => true

   scope :with_first_name, ->(value) { where("lower(first_name) like lower(?)", "%#{value}%") }
   scope :with_last_name,  ->(value) { where("lower(last_name) like lower(?)", "%#{value}%") }
   scope :with_email,      ->(value) { where("lower(email) like lower(?)", "%#{value}%") }
   scope :with_mobile,     ->(value) { where("lower(mobile) like lower(?)", "%#{value.gsub(/\s+/, '')}%") }
   scope :with_skill,      ->(value) { where("? = ANY(skills)", value) }
   scope :in_age_category, ->(value) { where age_category: age_categories[value] }

   before_validation(on: [:create, :update]) do
     clean_mobile!
   end


   before_create do
     self.mobile_confirmation_code = rand(1..9999).to_s.rjust(4, '0')
   end


   def name
     return "#{first_name} #{last_name}".strip if first_name?
     email
   end

   def humanized_age_category
     human_age_category age_category
   end

   def adults_in_family
     count = family_hash.count { |p| p['age_category'] == :adult.to_s }
     return count+1 if adult?
     count
   end

   def youth_in_family
     count = family_hash.count { |p| p['age_category'] == :youth.to_s }
     return count+1 if youth?
     count
   end

   def children_in_family
     family_hash.count { |p| p['age_category'] == :child.to_s }
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



   private

   def family_hash
     return JSON.parse family unless family.blank?
     {}
   end


   def human_age_category(category)
     return nil if category.nil?
     description = category.eql?(:adult.to_s) ? 'over 18' :
        category.eql?(:youth.to_s) ? '11 to 18' : 'under 11'
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

end
