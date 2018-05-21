class TextMessage < ApplicationRecord

  include Filterable

  scope :with_recipient, ->(value) { where("lower(recipients) like lower(?)", "%#{value}%") }

end
