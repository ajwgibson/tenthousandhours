class FileUpload

  include ActiveModel::Model
  include Uploadable

  attr_accessor :filename

  validates :filename, :presence => true

end
