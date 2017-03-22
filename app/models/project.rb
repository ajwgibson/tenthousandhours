class Project < ActiveRecord::Base

  acts_as_paranoid

  include Filterable

  validates :organisation_type, :presence => true
  validates :organisation_name, :presence => true

end
