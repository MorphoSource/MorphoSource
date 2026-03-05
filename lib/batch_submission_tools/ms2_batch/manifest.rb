module BatchSubmissionTools
  module Ms2Batch
    # Data for a batch submission of multiple media processed asynchronously in the background.
    # It is generated from a batch file (usually XLSX) and a JSON representation is stored in a
    # BackgroundJob object to be processed async by BatchSubmission jobs.
    class Manifest
      include BatchSubmissionTools::Ms2Batch::BatchSubmission
      attr_accessor :input_path, :input_data, :media_path, :admin_user, :depositor, :owner, :on_behalf_of,
        :organization_id, :organization_transfer_immediately, :device_id, :device_modality,
        :collection_ids, :fund_code_id,
        :rows, :media_group_to_rows, :rows_to_bso, :biological_specimen_ingests,
        :taxonomy_ingests, :rows_to_taxonomy, :media_ie_pe_ingests, :media_ownership_fields,
        :skipped_row_count, :summary

      def initialize(input_path: nil, input_data: nil, media_path:, admin_user:, depositor:, owner: nil, organization_id:, organization_transfer_immediately: false, device_id:, on_behalf_of: nil, collection_ids: [], fund_code_id: nil, media_ownership_fields:, modality:)
        if input_path.blank? && input_data.blank?
          raise ArgumentError, "Either input_path or input_data must be provided"
        end

        @input_path = input_path
        @input_data = input_data
        @media_path = media_path
        @admin_user = admin_user.user_key
        @depositor = depositor.user_key
        @owner = owner
        @on_behalf_of = on_behalf_of.present? ? on_behalf_of.user_key : nil
        @organization_id = organization_id
        @organization_transfer_immediately = organization_transfer_immediately
        @device_id = device_id
        @device_modality = modality
        @media_ownership_fields = media_ownership_fields

        @collection_ids = Array(collection_ids)
        @fund_code_id = fund_code_id

        @biological_specimen_ingests = []
        @rows_to_bso = {}

        @taxonomy_ingests = []
        @rows_to_taxonomy = {}

        @media_ie_pe_ingests = []

        @summary = {
          "depositor_id" => @depositor,
          "owner_id" => @owner,
          "organization_id" => @organization_id,
          "device_id" => @device_id,
          "collection_ids" => @collection_ids,
          "manifest_tmp_file" => @input_path,
          "media_files" => []
        }
        call
      end

      def call
        validate_media_path
        parse_manifest
        infer_media_relationships
        construct_biological_specimen_ingests
        construct_taxonomy_ingests
        construct_media_ie_pe_ingests
      end

      def validate_media_path
        Dir.exist?(media_path) ? true : raise("Media path directory (#{media_path}) not found")
      end

      def parse_manifest
        @rows, @skipped_row_count =
          if input_data.present?
            parse_input_rows(input_data)
          else
            parse_xlsx_split_sections(input_path)
          end
      end

      def infer_media_relationships
        @media_group_to_rows = rows.each_with_object({}).with_index do |(row, hash), index|
          sheet_index = [index]
          hash[sheet_index] = { raw_list: [], parents: [], derived_parents: [], children: [] } if !hash.key?(sheet_index)
          hash[sheet_index][:raw_list] << index
        end
        rows_to_remove = []
        derived_group_rows = {} #

        media_group_to_rows.each do |sheet_index, mg|
          parents = []
          derived_parents = []
          children = []

          mg[:raw_list].each do |row_index|
            row = rows[row_index]
            parent_index = ""
            derived_parent_index = ""
            # is parent?
            if row[:media][:parent_file].present?
              children << row_index
              # look for the parent row index
              rows.each_with_index do |r , idx|
                if (r[:media][:media_file]&.first == row[:media][:parent_file].first)
                  if r[:media][:raw_or_derived]&.first.downcase == "derived"
                    derived_parent_index = idx
                  else
                    parent_index = idx
                    rows_to_remove << row_index
                  end
                end
              end

              if parent_index.present?
                parents << parent_index
                media_group_to_rows[[parent_index]][:children] << row_index
              elsif derived_parent_index.present?
                parents << derived_parent_index
                # find the media group that ingest the derived parent
                derived_parents << derived_parent_index
                if derived_group_rows[[derived_parent_index]].present?
                  # combine children with a derived parent so they will be all ingested in one job.
                  # this will avoid race condition when children are created at the same time
                  media_group_to_rows[derived_group_rows[[derived_parent_index]]][:children] << row_index
                  rows_to_remove << row_index
                else
                  derived_group_rows[[derived_parent_index]] = [row_index]
                end
              end
            elsif row[:media][:parent_ms_id].present?
              children << row_index
            else
              # note that child with undeposited parent also falls in here
              parents << row_index
            end

            if parents.count > 1
              children = parents.drop(1) + children
              parents = parents.first
            end
            (media_group_to_rows[sheet_index][:parents] << parents).flatten!
            (media_group_to_rows[sheet_index][:derived_parents] << derived_parents).flatten!
            (media_group_to_rows[sheet_index][:children] << children).flatten!

            summary["media_files"] << row[:media][:media_file]&.first

          end # /mg[:raw_list]
        end # //media_group_to_rows

        # sort media group by group until no more media
        remain_mg = @media_group_to_rows.clone
        full_ordered_list = []
        begin
          ordered_list = group_with_hierarchy(remain_mg)
          if !ordered_list.present?
            raise "Something went wrong.  ordered_list return nothing"
          end
          full_ordered_list += ordered_list
          ordered_list.each do |key|
            remain_mg.delete(key)
          end
          Rails.logger.debug "iN Manifest: ordered_list #{ordered_list} removed. Remaining: #{remain_mg.keys}"
        end until remain_mg.empty?

        @media_group_to_rows = sort_by_order_list(@media_group_to_rows, full_ordered_list)

        if rows_to_remove.present?
          # when new parent media will be created,
          # Only the parent items of the media group is needed for ingest job for all media
          # otherwise duplicate media will be created
          rows_to_remove.each { |k| @media_group_to_rows.delete [k] }
        end

        # if there is a parent in a row removed, find the new parent and re-order if needed
        new_parents_for.each do |new_parent, child|
          move_item_in_front(full_ordered_list, new_parent, child)
          rows_to_remove.each { |k| full_ordered_list.delete [k] }
          @media_group_to_rows = sort_by_order_list(@media_group_to_rows, full_ordered_list)
        end

        unless new_parents_for.empty?
          raise "Sorry, there is an issue with the order of the media. Please contact morphosource@duke.edu (#{input_path})"
        end
        # //media_group_to_rows
        Rails.logger.debug "iN Manifest: media_group_to_rows: #{media_group_to_rows}"
      end

      def new_parents_for
        new_parents_for = {}
        to_be_created = []
        media_group_to_rows.each do |k, item|
          to_be_created << k
          to_be_created << item[:children] if item[:children].present?
          to_be_created = to_be_created.flatten.uniq
          if item[:parents].present? && !media_group_to_rows[item[:parents]].present? &&
            !to_be_created.include?(item[:parents][0])
            if (new_parent = media_group_to_rows.find { |_, v| v[:children].include?(item[:parents][0]) }).present?
              new_parents_for[new_parent[0]] = k
            end
          end
        end
        new_parents_for
      end

      def sort_by_order_list(mg, ordered_list)
        ordered_list.map { |index| [index, mg[index]] }.to_h
      end

      def move_item_in_front(array, x, y)
        array.delete(x)
        y_index = array.index(y)
        array.insert(y_index, x)
        array
      end

      def group_with_hierarchy(mg)
        # re-order rows to have parent > child ingestion order
        hierarchy = []
        largest_hierarchy = []
        # sort list by hierarchy
        mg.each do |key, value|
          item_hierarchy = []
          # Add the current item to the hierarchy array
          item_hierarchy << key
          # Traverse the parents of the current item until reaching the root parent
          parent = value[:parents]
          while parent.present? && parent != key
            if mg[parent].nil? || mg[parent][:parents].nil?
              # Parent not found, exit the loop
              break
            end
            item_hierarchy.unshift(parent)  # Add the parent at the beginning of the hierarchy array
            if mg[parent][:parents] == parent
              break # parent is itself, exit
            end
            parent = mg[parent][:parents]
          end
          if item_hierarchy.length > largest_hierarchy.length
            largest_hierarchy = item_hierarchy
          end
          hierarchy << item_hierarchy
        end
        return largest_hierarchy
      end

      def construct_biological_specimen_ingests
        rows.each_with_index do |row, index|
          bso = normalize_biological_specimen_attrs(row)

          if !bso.present?
            raise "Empty biological specimen issue"
          end
          matching_bso_index = match_bsos(bso)
          if matching_bso_index.present?
            rows_to_bso[index] = matching_bso_index
          else
            # proceed with constructing ingest
            bso_ingest = BatchSubmissionTools::Ms2Batch::Models::BiologicalSpecimenManifest.new(
              initial_attrs: bso,
              depositor: depositor,
              on_behalf_of: on_behalf_of,
              organization_id: organization_id
            )
            biological_specimen_ingests << bso_ingest
            rows_to_bso[index] = biological_specimen_ingests.count - 1
          end
        end
      end

      def normalize_biological_specimen_attrs(row)
        bso = row[:biological_specimen]
        media = row[:media] || {}

        if media[:parent_ms_id].present?
          parent_ms_id = media[:parent_ms_id].first
          if (specimen_id = parent_media_specimen_id(parent_ms_id)).present?
            return { ms_id: [specimen_id] }
          else
            raise "Unable to resolve biological specimen for parent media #{parent_ms_id}"
          end
        end

        return bso
      end

      def parent_media_specimen_id(parent_ms_id)
        parent_media_id = pad(parent_ms_id)
        @parent_media_specimen_ids ||= {}
        @parent_media_specimen_ids[parent_media_id] ||= begin
          parent_media = SolrDocument.find(parent_media_id)
          parent_media["physical_object_id_ssim"].first
        end
      end

      # Match :biological_specimen hash from @rows to previously constructed BSO ingests to catch duplicates
      def match_bsos(bso_hash)
        biological_specimen_ingests.each_with_index do |s, index|
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
              occurrence_id: bso.work_imported ? bso.occurrence_id : nil
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
        media_group_to_rows.each do |sheet_index, mg|
          if mg[:parents].count > 1
            raise "Multiple parent error"
          end

          # Is there a parent? If so, get IE and parent PE/media ingest from it. Otherwise, get IE from first child
          if mg[:parents].present?
            parent_row_index = mg[:parents].first
            media_attrs = rows[parent_row_index][:media]

            raw_or_derived = media_attrs[:raw_or_derived]&.first&.downcase
            if parent_row_index == sheet_index.first && raw_or_derived == "raw"

              ie_row_index = parent_row_index

              parent_media = BatchSubmissionTools::Ms2Batch::Models::MediaManifest.new(
                initial_attrs: media_attrs,
                depositor: depositor,
                owner: owner,
                on_behalf_of: on_behalf_of,
                organization_id: organization_id,
                media_path: media_path,
                media_ownership_fields: media_ownership_fields
              )
              parent = {
                parent_row_index =>
                  BatchSubmissionTools::Ms2Batch::Models::MediaPeManifest.new(media: parent_media)
              }

            else
              ie_row_index = parent_row_index
              parent_pe = BatchSubmissionTools::Ms2Batch::Models::ProcessingEventManifest.new(
                initial_attrs: rows[parent_row_index][:processing_event],
                depositor: depositor,
                on_behalf_of: on_behalf_of
              )

              media_attrs = rows[parent_row_index][:media]
              parent_media = BatchSubmissionTools::Ms2Batch::Models::MediaManifest.new(
                initial_attrs: media_attrs,
                depositor: depositor,
                owner: owner,
                on_behalf_of: on_behalf_of,
                organization_id: organization_id,
                media_path: media_path,
                media_ownership_fields: media_ownership_fields
              )
              parent = {
                parent_row_index =>
                  BatchSubmissionTools::Ms2Batch::Models::MediaPeManifest.new(media: parent_media, pe: parent_pe)
              }

            end
          else
            # if parent_ms_id exists, get the existing parent
            if rows[mg[:children].first][:media][:parent_ms_id].present?
              media_attrs = {
                ms_id: pad(rows[mg[:children].first][:media][:parent_ms_id].first)
              }
              parent_media = BatchSubmissionTools::Ms2Batch::Models::MediaManifest.new(
                initial_attrs: media_attrs
              )
              parent = {
                "existing" => BatchSubmissionTools::Ms2Batch::Models::MediaPeManifest.new(media: parent_media)
              }
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

          children = mg[:children].map do |row_index|

            if mg[:derived_parents].present?
              # mark the ingest with dependency
              derived_parent_file = rows[row_index][:media][:parent_file].first
            end

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
              media_ownership_fields: media_ownership_fields,
              derived_parent_file: derived_parent_file
            )

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
          summary: summary,
          biological_specimen_ingests: biological_specimen_ingests.map(&:to_h),
          rows_to_bso: rows_to_bso.transform_keys(&:to_s),
          taxonomy_ingests: taxonomy_ingests.map(&:to_h),
          rows_to_taxonomy: rows_to_taxonomy.transform_keys(&:to_s),
          media_ie_pe_ingests: media_ie_pe_ingests.map(&:to_h),
          collection_ids: collection_ids,
          fund_code_id: fund_code_id,
          organization_transfer_immediately: organization_transfer_immediately,
          skipped_row_count: skipped_row_count
        }.deep_stringify_keys
      end

      def convert(obj)
        obj.map(&:to_h) #obj.map(&:to_json)
      end

    end
  end
end
