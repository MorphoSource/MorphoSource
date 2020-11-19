module Ms1to2
  class ImportWorkRelationships
    attr_accessor :input_csv

    def initialize(input_csv)
      @input_csv = input_csv
    end

    def call
      CSVParser.new(input_csv).each do |attrs|
        if attrs[:parent_id]&.first.present? && attrs[:child_ids].present?
          if attrs[:child_ids].length > 1000
            AddWorkChildrenLoopJob.perform_later(
              attrs[:parent_id].first, 
              attrs[:child_ids]
            )
          else
            AddWorkChildrenJob.perform_later(
              attrs[:parent_id].first, 
              attrs[:child_ids]
            )
          end
        end
      end
    end
  end
end
