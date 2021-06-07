module Ms1to2
  class Ms1BatchFileConverter
    attr_accessor :input_path, :input_data

    def self.call(input_path)
      new(input_path).call
    end

    def initialize(input_path)
      @input_path = input_path
    end

    def call
      parse_input_data
      return input_data
    end

    def parse_input_data
      @input_data = []
      Ms1to2::CSVParser.new(input_path, false).each do |row|
        input_data.concat hashify(row)
      end
    end

    def hashify(row)
      row_data = {}

      # break up each row into sections
      row.each do |field_terms, val|
        model, field = field_terms.to_s.split('.', 2)
        row_data[model] = {} if !row_data.key?(model)

        # special handling for ms_media_files
        if model == 'ms_media_files'
          media_field, media_number = field.to_s.split('.', 2)
          row_data[model][media_number] = {} if !row_data[model].key?(media_number)
          row_data[model][media_number][media_field] = val
        else
          row_data[model][field] = val
        end
      end

      final_hashes = []

      # how many media files are present?
      row_data['ms_media_files'].each do |key, h|
        next unless h.values.any? { |x| x.present? }
        final_hashes << row_data.except('ms_media_files').merge('ms_media_file' => h)
      end
      
      return final_hashes
    end
  end
end