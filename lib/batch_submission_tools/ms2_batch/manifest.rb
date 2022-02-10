module BatchSubmissionTools
  module Ms2Batch
    class Manifest
      include BatchSubmissionTools::Ms2Batch::BatchSubmissionHelper
      attr_accessor :input_path, :media_path, :admin_user, :depositor, :on_behalf_of,
        :organization_id, :device_id, :device_modality, :collection_ids, :fund_code_id,
        :rows, :media_group_to_rows, :rows_to_bso, :biological_specimen_ingests, 
        :taxonomy_ingests, :rows_to_taxonomy, :media_ie_pe_ingests, :media_ownership_fields

      def initialize(input_path:, media_path:, admin_user:, depositor:, organization_id:, device_id:, on_behalf_of: nil, collection_ids: [], fund_code_id: nil, media_ownership_fields:)
        @input_path = input_path
        @media_path = media_path
        @admin_user = admin_user.user_key
        @depositor = depositor.user_key
        @on_behalf_of = on_behalf_of.present? ? on_behalf_of.user_key : nil
        @organization_id = organization_id
        @device_id = device_id
        @device_modality = Device.find(device_id).modality&.first
        @media_ownership_fields = media_ownership_fields

        @collection_ids = Array(collection_ids)
        @fund_code_id = fund_code_id

        @biological_specimen_ingests = []
        @rows_to_bso = {}

        @taxonomy_ingests = []
        @rows_to_taxonomy = {}

        @media_ie_pe_ingests = []

        call
      end

      def call
        validate_media_path
        parse_manifest
        infer_media_relationships
        construct_biological_specimen_ingests
        construct_taxonomy_ingests
#byebug

#(byebug)  @taxonomy_ingests.first
#<BatchSubmissionTools::Ms2Batch::Models::TaxonomyManifest:0x00007f4d53a144b8 @initial_attrs={:taxonomy_genus=>["Myrmoteras"], :taxonomy_species=>["iriodum"], :taxonomy_subspecies=>[]}, @depositor="f47534", @on_behalf_of=nil, @canonical=false, @id=nil, @work=nil, @attrs={:depositor=>"f47534", :on_behalf_of=>nil, :taxonomy_genus=>["Myrmoteras"], :taxonomy_species=>["iriodum"], :taxonomy_subspecies=>[], :visibility=>"open", :work_parents_attributes=>{}}>

#(byebug)  @taxonomy_ingests.first.id
#nil

        construct_media_ie_pe_ingests
      end

      def validate_media_path
        Dir.exists?(media_path) ? true : raise("Media path directory (#{media_path}) not found")
      end

      def parse_manifest
        @rows = parse_xlsx_split_sections(input_path)
      end

      def infer_media_relationships
        @media_group_to_rows = rows.each_with_object({}).with_index do |(row, hash), index|
          sheet_index = [index]
          hash[sheet_index] = { raw_list: [], parents: [], children: [] } if !hash.key?(sheet_index)
          hash[sheet_index][:raw_list] << index
        end
        rows_to_remove = []

        media_group_to_rows.each do |sheet_index, mg|
          parents = []
          children = []

          mg[:raw_list].each do |row_index|
            row = rows[row_index]
            # is parent?
            if row[:media][:parent_file].present? 
              children << row_index
              rows_to_remove << row_index
              # look for the parent row index
              parent_index = rows.index { |r| r[:media][:media_file]&.first == row[:media][:parent_file].first }
              parents << parent_index
              media_group_to_rows[[parent_index]][:children] << row_index
            elsif row[:media][:parent_ms_id].present?
              children << row_index
            else
              parents << row_index
            end

            if parents.count > 1
              children = parents.drop(1) + children
              parents = parents.first
            end
            (media_group_to_rows[sheet_index][:parents] << parents).flatten!
            (media_group_to_rows[sheet_index][:children] << children).flatten!

          end # /mg[:raw_list]
        end # /media_group_to_rows

        if rows_to_remove.present?
          # when new parent media will be created,
          # Only the parent items of the media group is needed for ingest job for all media
          # otherwise duplicate media will be created
          rows_to_remove.each { |k| media_group_to_rows.delete [k] }
        end
#byebug          

      end

      def construct_biological_specimen_ingests
        rows.pluck(:biological_specimen).each_with_index do |bso, index|
          if !bso.present?
            raise "Empty biological specimen issue"
          end
          matching_bso_index = match_bsos(bso)
          if matching_bso_index.present?
#byebug
            rows_to_bso[index] = matching_bso_index
          else
            # proceed with constructing ingest
#byebug
            bso_ingest = BatchSubmissionTools::Ms2Batch::Models::BiologicalSpecimenManifest.new(
              initial_attrs: bso, 
              depositor: depositor, 
              on_behalf_of: on_behalf_of,
              organization_id: organization_id
            )
#byebug
            biological_specimen_ingests << bso_ingest
            rows_to_bso[index] = biological_specimen_ingests.count - 1
          end
        end
      end

      # Match :biological_specimen hash from @rows to previously constructed BSO ingests to catch duplicates
      def match_bsos(bso_hash)
#byebug
        biological_specimen_ingests.each_with_index do |s, index| 
#byebug
          if 
            (
              bso_hash[:ms_id]&.present? &&
              bso_hash[:ms_id]&.first == s.id 
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

            bso_taxonomies = BatchSubmissionTools::Ms2Batch::Factory::TaxonomyManifests.call(
              attrs: taxonomy_attrs,
              admin_user: admin_user,
              depositor: depositor,
              on_behalf_of: on_behalf_of,
              idigbio_uuid: bso.work_imported ? bso.idigbio_uuid : nil
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
#byebug

        # iterating through each media group
        media_group_to_rows.each do |sheet_index, mg|
          if mg[:parents].count > 1
            raise "Multiple parent error"
          end

          # Is there a parent? If so, get IE and parent PE/media ingest from it. Otherwise, get IE from first child
          if mg[:parents].present?
            parent_row_index = mg[:parents].first
            ie_row_index = parent_row_index
            parent_pe = BatchSubmissionTools::Ms2Batch::Models::ProcessingEventManifest.new(
              initial_attrs: rows[parent_row_index][:processing_event],
              depositor: depositor,
              on_behalf_of: on_behalf_of
            )


            media_attrs = rows[parent_row_index][:media]
#byebug
            parent_media = BatchSubmissionTools::Ms2Batch::Models::MediaManifest.new(
              initial_attrs: media_attrs,
              depositor: depositor,
              on_behalf_of: on_behalf_of,
              organization_id: organization_id,
              media_path: media_path,
              media_ownership_fields: media_ownership_fields
            )
            parent = {
              parent_row_index => 
                BatchSubmissionTools::Ms2Batch::Models::MediaPeManifest.new(media: parent_media, pe: parent_pe)
            }

#byebug
          else
            # if parent_ms_id exists, get the existing parent 
            if rows[mg[:children].first][:media][:parent_ms_id].present?

              media_attrs = { 
                ms_id: rows[mg[:children].first][:media][:parent_ms_id].first
              }
              parent_media = BatchSubmissionTools::Ms2Batch::Models::MediaManifest.new(
                initial_attrs: media_attrs
#                depositor: depositor,
#                on_behalf_of: on_behalf_of,
#                organization_id: organization_id,
#                media_path: media_path,
#                media_ownership_fields: media_ownership_fields
              )
#byebug
              parent = {
                "existing" => BatchSubmissionTools::Ms2Batch::Models::MediaPeManifest.new(media: parent_media)
              }
#byebug
              
            end

            ie_row_index = mg[:children].first
          end

          imaging_event = {
            ie_row_index => BatchSubmissionTools::Ms2Batch::Models::ImagingEventManifest.new(
              initial_attrs: rows[ie_row_index][:imaging_event],
              device_id: device_id,
              device_modality: device_modality,
              depositor: depositor,
              on_behalf_of: on_behalf_of
            )
          }
#byebug

          children = mg[:children].map do |row_index|
            child_pe = BatchSubmissionTools::Ms2Batch::Models::ProcessingEventManifest.new(
              initial_attrs: rows[row_index][:processing_event],
              depositor: depositor,
              on_behalf_of: on_behalf_of
            )
            child_media = BatchSubmissionTools::Ms2Batch::Models::MediaManifest.new(
              initial_attrs: rows[row_index][:media],
              depositor: depositor,
              on_behalf_of: on_behalf_of,
              organization_id: organization_id,
              media_path: media_path,
              media_ownership_fields: media_ownership_fields
            )
#byebug

            [
              row_index,
              BatchSubmissionTools::Ms2Batch::Models::MediaPeManifest.new(
                media: child_media,
                pe: child_pe
              )
            ]
          end.to_h

          media_ie_pe_ingests << BatchSubmissionTools::Ms2Batch::Models::MediaIePeManifest.new(
            imaging_event: imaging_event, 
            parent: parent, 
            children: children
          )
        end # / media_group_to_rows.each
      end

      # Must convert entire object to hash for ActiveJob serialization
      def to_h
        {
          biological_specimen_ingests: biological_specimen_ingests.map(&:to_h),
          rows_to_bso: rows_to_bso.transform_keys(&:to_s),
          taxonomy_ingests: taxonomy_ingests.map(&:to_h),
          rows_to_taxonomy: rows_to_taxonomy.transform_keys(&:to_s),
          media_ie_pe_ingests: media_ie_pe_ingests.map(&:to_h),
          collection_ids: collection_ids,
          fund_code_id: fund_code_id
        }.deep_stringify_keys
      end

      def convert(obj)
        tmp = obj.map(&:to_h) #obj.map(&:to_json)
byebug

        return tmp
      end

    end
  end
end
