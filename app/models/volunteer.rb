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

end
