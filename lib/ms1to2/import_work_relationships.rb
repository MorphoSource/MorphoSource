module Ms1to2
  class ImportWorkRelationships
    attr_accessor :input_csv, :delete_previous_children

    def initialize(input_csv, delete_previous_children=false)
      @input_csv = input_csv
      @delete_previous_children = delete_previous_children
    end

    def call
      CSVParser.new(input_csv).each do |attrs|
        if attrs[:parent_id]&.first.present? && attrs[:child_ids]&.first.present?
          AddWorkChildrenJob.perform_later(
            attrs[:parent_id].first, 
            attrs[:child_ids].first,
            delete_previous_children
          )
        end
      end
    end
  end
end