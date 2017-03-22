require 'rails_helper'

RSpec.describe FileUpload, type: :model do

  it "is invalid without a filename" do
    expect(FileUpload.new).not_to be_valid
  end

end
