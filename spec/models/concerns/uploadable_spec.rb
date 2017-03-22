require 'rails_helper'
require 'stringio'

RSpec.describe Uploadable, type: :concern do

  class Upload
    include Uploadable
  end


  describe "#upload_file" do

    let(:upload) { Upload.new }

    let(:io) {
      StringIO.new("Hello world").tap do |s|
        s.class.module_eval { attr_accessor :original_filename}
        s.original_filename = 'filename.csv'
      end
    }

    def clear_uploads
      FileUtils.rm Dir.glob(Rails.root.join('public', 'uploads', '*'))
    end

    before(:each) do
      clear_uploads
    end

    after(:each) do
      clear_uploads
    end

    it "creates the upload folder if that didn't already exist" do
      folder = Rails.root.join('public', 'uploads')
      FileUtils.remove_dir(folder, true)
      upload.upload_file io
      expect(Dir.exist?(folder)).to be true
    end

    it "stores the uploaded file in the uploads folder" do
      upload.upload_file io
      expect(File.exist?(Rails.root.join('public', 'uploads', 'filename.csv'))).to be true
    end

    it "returns the path to the uploaded file" do
      result = upload.upload_file io
      expect(result).to eq(Rails.root.join('public', 'uploads', 'filename.csv').to_s)
    end

  end

end
