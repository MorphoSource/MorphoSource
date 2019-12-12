module Importer
  class Checksum < ::ApplicationRecord
    self.table_name = 'importer_checksums'

    def self.import_data(checksum_filepath)
      File.open(checksum_filepath, 'r') do |file|
        file.each_line do |line|
          checksum, path = line.chomp.split(' ',2)
          find_or_initialize_by(path: path).update_attributes!(value: checksum)
        end
      end
    end

    def self.checksum(filepath)
      if record = find_by(path: filepath)
        record.value
      end
    end

  end
end
