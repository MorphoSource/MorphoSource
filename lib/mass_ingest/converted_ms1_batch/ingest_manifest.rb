module MassIngest
  module ConvertedMs1Batch
    class IngestManifest
      include MassIngest::ConvertedMs1Batch::MassIngestHelper

      attr_accessor :input_path, :depositor, :organization_id, :organization, :device_id, :device, :device_modality
      attr_accessor :rows, :media_groups, :rows_to_bso
      attr_accessor :biological_specimen_ingests, :taxonomy_ingests, :media_ingests

      def self.call(input_path, depositor, organization_id, device_id)
        new(input_path, depositor, organization_id, device_id).call
      end

      def initialize(input_path, depositor, organization_id, device_id)
        @input_path = input_path
        @depositor = depositor
        @organization_id = organization_id
        @organization = Organization.find(organization_id)
        @device_id = device_id
        @device = Device.find(device_id)
        @device_modality = device.modality
      end

      def call
        validate_manifest
        parse_manifest
        infer_media_relationships
        construct_biological_specimen_ingests
        return [biological_specimen_ingests, rows_to_bso]
      end

      def validate_manifest
        MassIngest::ConvertedMs1Batch::ValidateManifest.call(input_path)
      end

      def parse_manifest
        @rows = parse_csv_split_sections(input_path)
      end

      def infer_media_relationships
        @media_groups = rows.each_with_object({}) do |media, hash|
          orig_idx = media[:metadata][:original_index]
          hash[orig_idx] = [] if !hash.key?(orig_idx)
          hash[orig_idx] << media
        end

        # TODO: arrange media within media groups based on hierarchy algorithm

        @media_groups = media_groups
      end

      def construct_biological_specimen_ingests
        @biological_specimen_ingests = []
        @rows_to_bso = {}

        rows.pluck(:biological_specimen).each_with_index do |bso, index|
          if !bso.present?
            raise "Empty biological specimen issue"
          end

          matching_bsos = match_bsos(bso)
          if matching_bsos.count > 1
            raise "Duplicate BSO issue"
          elsif matching_bsos.count == 1
            rows_to_bso[index] = matching_bsos.first
            next
          else
            # proceed with constructing ingest
            bso_ingest = MassIngest::ConvertedMs1Batch::Models::BiologicalSpecimen.new(
              bso, 
              depositor, 
              organization_id
            )
            biological_specimen_ingests << bso_ingest
            rows_to_bso[index] = bso_ingest
            next
          end
        end
      end

      # Match :biological_specimen hash from @rows to previously constructed BSO ingests to catch duplicates
      def match_bsos(bso_hash)
        biological_specimen_ingests.select do |s| 
          (
            bso_hash[:id]&.present? &&
            bso_hash[:id]&.first == s.biological_specimen_id 
          ) ||
          ( 
            bso_hash[:occurrence_id].present? &&
            bso_hash[:occurrence_id]&.first&.downcase == s.occurrence_id&.downcase
          ) ||
          (
            bso_hash[:catalog_number].present? &&
            bso_hash[:catalog_number]&.first&.downcase == s.catalog_number&.downcase &&
            bso_hash[:collection_code]&.first&.downcase == s.collection_code&.downcase &&
            bso_hash[:institution_code]&.first&.downcase == s.institution_code&.downcase
          )
        end
      end

      def perform_ingest

      end
    end
  end
end