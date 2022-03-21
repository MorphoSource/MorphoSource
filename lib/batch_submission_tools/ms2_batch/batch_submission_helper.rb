module BatchSubmissionTools
  module Ms2Batch
    module BatchSubmissionHelper

      def parse_xlsx_split_sections(input_path)
        input_data = []
        ::Morphosource::Ms2Batch::XLSXParser.new(input_path, false, false).each do |row|
          input_data << split_sections(row)
        end
        return input_data
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