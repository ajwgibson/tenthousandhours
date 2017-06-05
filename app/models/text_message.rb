class TextMessage < ActiveRecord::Base

  include Filterable

  scope :with_recipient, ->(value) { where("lower(recipients) like lower(?)", "%#{value}%") }

end
