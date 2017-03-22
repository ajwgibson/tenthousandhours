module Uploadable

  extend ActiveSupport::Concern

    def upload_file(io)

      folder = Rails.root.join('public', 'uploads')
      Dir.mkdir(folder) unless Dir.exist?(folder)

      destination = folder.join(io.original_filename)
      File.open(destination, 'wb') do |file|
        file.write(io.read)
      end

      destination.to_s

    end

end
