module BatchSubmissionTools
  module Ms2Batch
    module BatchSubmissionHelper
 
      def empty_row?(row)
        row.each do |cell|
          if cell[1].present?
            if cell[1].first.squish.length > 0
              return false
            end
          end
        end
        return true
      end

      def parse_xlsx_split_sections(input_path)
        input_data = []
        skipped_row_count = 0
        ::Morphosource::Ms2Batch::XLSXParser.new(input_path, false, false).each do |row|
          if empty_row?(row)
            skipped_row_count += 1
          else
            input_data << split_sections(row) 
          end
        end
        return input_data, skipped_row_count
      end

      def split_sections(row)
        row_data = {}
        # break up each row into sections
        row.each do |field_terms, val|
          field_terms_ary = field_terms.to_s.split('.', 3)
          model = field_terms_ary.first.to_sym
          field = field_terms_ary.last.to_sym
          row_data[model] = {} if !row_data.key?(model)
          row_data[model][field] = val.map(&:to_s) 
          # Note: Values will be converted (e.g. from float) to strings, to avoid Invalid datatype error in Solrizer::InvalidIndexDescriptor
        end
        return row_data
      end
    end
  end
end