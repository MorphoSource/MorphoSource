module MassIngest
  module ConvertedMs1Batch
    class Manifest
      include MassIngest::ConvertedMs1Batch::MassIngestHelper

      attr_accessor :input_path, :media_path, :admin_user, :depositor
      attr_accessor :organization_id, :organization, :device_id, :device, :device_modality
      attr_accessor :rows, :media_group_to_rows, :rows_to_bso
      attr_accessor :biological_specimen_ingests, :rows_to_bso
      attr_accessor :taxonomy_ingests, :rows_to_taxonomy
      attr_accessor :media_ie_pe_ingests

      # Rewrite call as something that calls the relevant job?
      # def self.call(input_path, media_path, admin_user, depositor, organization_id, device_id)
      #   new(input_path, media_path, admin_user, depositor, organization_id, device_id).call
      # end

      def initialize(input_path, media_path, admin_user, depositor, organization_id, device_id)
        @input_path = input_path
        @media_path = media_path
        @admin_user = admin_user
        @depositor = depositor
        @organization_id = organization_id
        @organization = Organization.find(organization_id)
        @device_id = device_id
        @device = Device.find(device_id)
        @device_modality = device.modality&.first

        @biological_specimen_ingests = []
        @rows_to_bso = {}

        @taxonomy_ingests = []
        @rows_to_taxonomy = {}

        @media_ie_pe_ingests = []

        call
      end

      def call
        # validate_media_path # re-add this after initial testing
        validate_manifest
        parse_manifest
        infer_media_relationships
        construct_biological_specimen_ingests
        construct_taxonomy_ingests
        construct_media_ie_pe_ingests
      end

      def validate_media_path
        Dir.exists?(media_path) ? true : raise("Media path directory (#{media_path}) not found")
      end

      def validate_manifest
        MassIngest::ConvertedMs1Batch::ValidateManifest.call(input_path)
      end

      def parse_manifest
        @rows = parse_csv_split_sections(input_path)
      end

      def infer_media_relationships
        @media_group_to_rows = rows.each_with_object({}).with_index do |(row, hash), index|
          ms1_sheet_index = row[:metadata][:original_index]
          hash[ms1_sheet_index] = { raw_list: [], parents: [], children: [] } if !hash.key?(ms1_sheet_index)
          hash[ms1_sheet_index][:raw_list] << index
        end

        media_group_to_rows.each do |ms1_sheet_index, mg|
          parents = []
          children = []

          mg[:raw_list].each do |row_index|
            row = rows[row_index]

            # is parent?
            if (
              row[:metadata][:raw_or_derived]&.first&.to_i == 1 || 
              File.extname(row[:media][:media_file]&.first.to_s).downcase == ".zip"
            )
              parents << row_index
            else
              children << row_index
            end

            if parents.count > 1
              children = parents.drop(1) + children
              parents = parents.first
            end

            media_group_to_rows[ms1_sheet_index][:parents] = parents
            media_group_to_rows[ms1_sheet_index][:children] = children
          end
        end
        # TODO: arrange media within media groups based on hierarchy algorithm
      end

      def construct_biological_specimen_ingests
        rows.pluck(:biological_specimen).each_with_index do |bso, index|
          if !bso.present?
            raise "Empty biological specimen issue"
          end

          matching_bso_index = match_bsos(bso)
          if matching_bso_index.present?
            rows_to_bso[index] = matching_bso_index
          else
            # proceed with constructing ingest
            bso_ingest = MassIngest::ConvertedMs1Batch::Models::BiologicalSpecimen.new(
              bso, 
              depositor, 
              organization_id
            )
            biological_specimen_ingests << bso_ingest
            rows_to_bso[index] = biological_specimen_ingests.count - 1
          end
        end
      end

      # Match :biological_specimen hash from @rows to previously constructed BSO ingests to catch duplicates
      def match_bsos(bso_hash)
        biological_specimen_ingests.each_with_index do |s, index| 
          if 
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
            return index
          end
        end
        return nil
      end

      # Construct 1+ ingests for taxonomies associated with BSO
      def construct_taxonomy_ingests
        rows.pluck(:taxonomy).each_with_index do |taxonomy_attrs, index|
          bso = biological_specimen_ingests[rows_to_bso[index]]

          # construct taxonomies if necessary (i.e., if BSO is to be created)
          if bso.attrs.present?
            # skip unless there are taxonomy attributes to use or we can get taxonomy from iDigBio
            next unless taxonomy_attrs.values.any? { |v| v.present? } || bso.work_imported

            bso_taxonomies = MassIngest::ConvertedMs1Batch::Factory::Taxonomy.call(
              taxonomy_attrs,
              admin_user,
              depositor,
              bso.work_imported ? bso.idigbio_uuid : nil
            )

            bso_taxonomies.each do |taxonomy|
              matching_taxonomy_index = match_taxonomies(taxonomy)
              if matching_taxonomy_index.present?
                rows_to_taxonomy[index] = [] if !rows_to_taxonomy.key?(index)
                rows_to_taxonomy[index] << matching_taxonomy_index
              else
                taxonomy_ingests << taxonomy
                rows_to_taxonomy[index] = [] if !rows_to_taxonomy.key?(index)
                rows_to_taxonomy[index] << taxonomy_ingests.count - 1
              end
            end
          end
        end
      end

      def match_taxonomies(new_taxonomy_ingest)
        taxonomy_ingests.each_with_index do |t, index|
          if
            (
              new_taxonomy_ingest.id.present? &&
              new_taxonomy_ingest.id == t.id
            ) ||
            (
              new_taxonomy_ingest.attrs.present? &&
              new_taxonomy_ingest.attrs == t.attrs
            )
            return index
          end
        end
        return nil
      end

      def construct_media_ie_pe_ingests
        # iterating through each media group
        media_group_to_rows.each do |ms1_sheet_index, mg|
          if mg[:parents].count > 1
            raise "Multiple parent error"
          end

          # Is there a parent? If so, get IE and parent PE/media ingest from it. Otherwise, get IE from first child
          if mg[:parents].present?
            parent_row_index = mg[:parents].first

            ie_row_index = parent_row_index

            parent = {
              parent_row_index => 
                MassIngest::ConvertedMs1Batch::Models::CombinedProcessingEventMedia.new(
                  rows[parent_row_index][:processing_event],
                  rows[parent_row_index][:media],
                  depositor,
                  media_path
                )
            }
          else
            ie_row_index = mg[:children].first
          end

          imaging_event = {
            ie_row_index => MassIngest::ConvertedMs1Batch::Models::ImagingEvent.new(
              rows[ie_row_index][:imaging_event],
              device_id,
              device_modality,
              depositor
            )
          }
          
          children = mg[:children].map do |row_index|
            [
              row_index,
              MassIngestConvertedMs1Batch::Models::CombinedProcessingEventMedia.new(
                rows[row_index][:processing_event],
                rows[row_index][:media],
                depositor,
                media_path
              )
            ]
          end.to_h

          media_ie_pe_ingests << MassIngest::ConvertedMs1Batch::Models::MediaIePe.new(imaging_event, parent, children)
        end
      end

      # Must convert entire object to hash for ActiveJob serialization
      def to_h
        {
          biological_specimen_ingests: biological_specimen_ingests.map(&:to_h),
          rows_to_bso: rows_to_bso.transform_keys(&:to_s),
          taxonomy_ingests: taxonomy_ingests.map(&:to_h),
          rows_to_taxonomy: rows_to_taxonomy.transform_keys(&:to_s),
          media_ie_pe_ingests: media_ie_pe_ingests.map(&:to_h)
        }
      end
    end
  end
end