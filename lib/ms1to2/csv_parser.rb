module Ms1to2
  # Taken from Duke RDR Importer Module Written By Jim Coble, Only Minor Modifications Made
  class CSVParser
    include Enumerable

    attr_reader :file_name

    def initialize(file_name)
      @file_name = file_name
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
      return unless val
      extract_multi_value_field(header, val, processed)
    end

    def extract_multi_value_field(header, val, processed, key = nil)
      key ||= header.to_sym
      processed[key] ||= []
      processed[key] += val.split(";").map(&:strip)
    end

    def as_csv_table
      @csv_table ||= CSV.read(file_name, headers: true, :encoding => 'ISO-8859-1')
    end

  end
end
