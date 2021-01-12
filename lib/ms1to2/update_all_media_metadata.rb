module Ms1to2
  class UpdateAllMediaMetadata
    attr_accessor :input_csv

    def initialize(input_csv)
      @input_csv = input_csv
    end

    def call
      CSVParser.new(input_csv).each do |attrs|
        UpdateMediaMetadataJob.perform_now(attrs)
      end
    end
  end
end
