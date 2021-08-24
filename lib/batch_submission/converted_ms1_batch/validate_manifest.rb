module BatchSubmission
  module ConvertedMs1Batch
    class ValidateManifest
      include BatchSubmission::ConvertedMs1Batch::BatchSubmissionHelper

      attr_accessor :input_path, :ingest_data, :errors

      def self.call(input_path)
        new(input_path).call
      end

      def initialize(input_path)
        @input_path = input_path
        @errors = []
      end

      def call
        @ingest_data = parse_csv_split_sections(input_path)
        @ingest_data.each_with_index { |row, idx| validate_sections(row, idx) }
        
        if errors.present?
          raise "Ingest manifest did not pass validation. Errors: #{errors.join(' ; ')}"
        else
          return true
        end
      end

      def validate_sections(row, index)
        if !(required_sections - row.keys).empty? # all req sections present?
          errors << "Row at index #{index} is missing the following required sections: #{(required_sections - row.keys).join(', ')}."
        end

        row.each do |section, attrs|
          case section
          when :metadata
            validate_metadata(attrs, index)
          when :biological_specimen
            validate_biological_specimen(attrs, index)
          end
        end
      end

      def required_sections
        [:metadata, :biological_specimen, :taxonomy, :imaging_event, :processing_event, :media]
      end

      def validate_metadata(attrs, index)
        validate_required_field(attrs, :original_index, index)
      end

      def validate_biological_specimen(attrs, index)
        validate_required_field(attrs, [:id, :catalog_number, :occurrence_id], index, :any)
        if attrs[:id].present? && !BiologicalSpecimen.exists?(attrs[:id])
          errors << "Row at index #{index} includes a specimen ID (#{attrs[:id]}), but no existing specimen matches this ID."
        end
      end

      def validate_required_field(attrs, fields, index, condition=:all)
        fields = Array(fields)

        if condition == :all
          success = fields.map { |f| attrs[f].present? }.all?
        elsif condition == :any
          success = fields.map { |f| attrs[f].present? }.any?
        end

        if !success
          errors << "Row at index #{index} is missing values for #{ condition == :all ? 'all' : 'any one' } of the following required fields: #{fields.join(', ')}."
        end
      end
    end
  end
end