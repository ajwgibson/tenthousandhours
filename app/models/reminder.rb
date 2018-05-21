class Reminder < ApplicationRecord
  belongs_to :project
  belongs_to :volunteer
  validates :reminder_date, :presence => true
end
