class ManualSignUp

  include ActiveModel::Model

  attr_accessor :slot_id

  validates :slot_id, presence: true

end
