class PersonalProject < ApplicationRecord

  acts_as_paranoid
  belongs_to :volunteer

  validates :project_date, :presence => true
  validates :description,  :presence => true
  validates :volunteer_count, :presence => true, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates :duration, :presence => true, numericality: { greater_than_or_equal_to: 0.5, less_than_or_equal_to: 9.5 }


  def commitment
    duration * volunteer_count
  end

end
