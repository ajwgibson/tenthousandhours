require 'JSON'

class Volunteer < ActiveRecord::Base

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

end
