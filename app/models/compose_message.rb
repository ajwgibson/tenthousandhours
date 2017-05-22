class ComposeMessage

  include ActiveModel::Model

  attr_accessor :message_text

  validates :message_text, presence: true

end
