class User < ActiveRecord::Base

  # Include default devise modules. Others available are:
  # :confirmable,
  # :omniauthable,
  # :registerable,
  # :rememberable,

  devise :database_authenticatable,
         :recoverable,
         :trackable,
         :validatable,
         :timeoutable,
         :lockable
end
