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
     return nil if age_category.nil?
     age_category.eql?(:adult.to_s) ? 'Over 18' :
        age_category.eql?(:youth.to_s) ? '11 to 18' : 'Under 11'
   end

end
