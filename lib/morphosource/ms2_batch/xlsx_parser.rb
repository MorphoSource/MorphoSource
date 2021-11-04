require 'roo'

module Morphosource
    module Ms2Batch
      class XLSXParser
        include Enumerable

        attr_reader :file_name, :skip_blanks, :split_values

        def initialize(file_name, skip_blanks = true, split_values = true)
          @file_name = file_name
          @skip_blanks = skip_blanks
          @split_values = split_values
        end

        def headers
          @headers ||= xlsx.row(7).drop(2)
        end

        # @yieldparam attributes [Hash] the attributes from one row of the file
        def each(&_block)
          xlsx.each_row_streaming(offset: 7, pad_cells: true) do |row| 
            data_row = row.drop(2) 
            yield attributes(headers, data_row)
          end
        end

        def each_with_index(&_block)
          row_index = 8
          xlsx.each_row_streaming(offset: 7, pad_cells: true) do |row| 
            data_row = row.drop(2) # first two columns have no data
            yield attributes(headers, data_row), row_index
            row_index = row_index + 1
          end
        end

        #def parent_arks
        #  as_csv_table['parent_ark'].compact.uniq
        #end

        private

        def attributes(headers, row)
          {}.tap do |processed|
            headers.each_with_index do |header, index|
              extract_field(header, row[index]&.value, processed)
            end
          end
        end

        def extract_field(header, val, processed)
          return if skip_blanks && !val.present?
          val = '' if !val.present?
          extract_multi_value_field(header, val, processed)
        end

        def extract_multi_value_field(header, val, processed, key = nil)
          key ||= header.to_sym
          processed[key] ||= []
          if split_values
            processed[key] += val.split(";").map(&:strip)
          else
            processed[key] += val.present? ? Array(val) : []
          end
        end

        def xlsx
          @xlsx ||= Roo::Excelx.new(file_name)
        end

      end
    end
end