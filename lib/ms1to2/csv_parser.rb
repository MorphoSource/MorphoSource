require 'csv'

module Ms1to2
  # Taken from Duke RDR Importer Module Written By Jim Coble, Only Minor Modifications Made
  class CSVParser
    include Enumerable

    attr_reader :file_name, :skip_blanks, :split_values

    def initialize(file_name, skip_blanks = true, split_values = true)
      @file_name = file_name
      @skip_blanks = skip_blanks
      @split_values = split_values
    end

    def headers
      @headers = as_csv_table.headers.compact
    end

    # @yieldparam attributes [Hash] the attributes from one row of the file
    def each(&_block)
      as_csv_table.each do |row|
        yield attributes(headers, row)
      end
    end

    def each_with_index(&_block)
      as_csv_table.each_with_index do |row, index|
        yield attributes(headers, row), index
      end
    end

    def parent_arks
      as_csv_table['parent_ark'].compact.uniq
    end

    private

    def attributes(headers, row)
      {}.tap do |processed|
        headers.each_with_index do |header, index|
          extract_field(header, row[index], processed)
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

    def as_csv_table
      @csv_table ||= CSV.read(file_name, headers: true, :encoding => 'UTF-8')
    end

  end
end
