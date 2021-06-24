module MassIngest
  module ConvertedMs1Batch
    module MassIngestHelper
      def parse_csv_split_sections(input_path)
        input_data = []
        Ms1to2::CSVParser.new(input_path, false, false).each do |row|
          input_data << split_sections(row)
        end
        return input_data
      end

      def split_sections(row)
        row_data = {}

        # break up each row into sections
        row.each do |field_terms, val|
          model, field = field_terms.to_s.split('.', 2)
          row_data[model.to_sym] = {} if !row_data.key?(model.to_sym)
          row_data[model.to_sym][field.to_sym] = val
        end

        return row_data
      end
    end
  end
end