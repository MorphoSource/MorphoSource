module Ms1to2
  class ImportCollectionMembers
    attr_accessor :input_csv

    def initialize(input_csv)
      @input_csv = input_csv
    end

    def call
      CSVParser.new(input_csv).each do |attrs|
        if attrs[:collection_id]&.first.present? && attrs[:member_ids].present?
          AddCollectionMembersJob.perform_later(
            attrs[:collection_id].first, 
            attrs[:member_ids]
          )
        end
      end
    end
  end
end