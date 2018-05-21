class User < ApplicationRecord

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

  validates :email,                 :presence => true
  validates :first_name,            :presence => true
  validates :last_name,             :presence => true
  validates :role,                  :presence => true
  validates :password,              confirmation: true
  validates :password_confirmation, presence: true, on: :create


  ROLES = [
    :Organiser,
    :Overseer,
    :Coordinator,
    :Leader,
  ]

  def organiser?
    :Organiser.to_s.eql? role
  end

  def overseer?
    :Overseer.to_s.eql? role
  end

  def coordinator?
    :Coordinator.to_s.eql? role
  end

  def leader?
    :Leader.to_s.eql? role
  end


  def name
    "#{first_name} #{last_name}".strip
  end

end
