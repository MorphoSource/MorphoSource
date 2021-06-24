module MassIngest
  module ConvertedMs1Batch
    module Models
      # Takes multiple individual-media hashes, generates params with relationships and ordering
      class MediaGroupIngest
        attr_accessor :media_group_hash, :depositor, :organization_id, :device_id, :device_modality
        attr_accessor :biological_specimen_id, :biological_specimen_imported, :biological_specimen_params
        attr_accessor :taxonomy_id_array, :taxonomy_params_array

        def initialize(media_group_hash, depositor, organization_id, device_id, device_modality)
          @depositor = depositor
          @media_group_hash = media_group_hash
          @organization_id = organization_id
          @device_id = device_id
          @device_modality = device_modality

          if media_group_hash.present? && organization_id.present? && device_id.present? && device_modality.present?
            construct_biological_specimen_ingest
            #construct_taxonomy_ingest
            #construct_media_works_ingest
          end

          # todo figure out return logic
        end

        def construct_biological_specimen_ingest
          attrs = @media_group_hash.first[:biological_specimen]

          # match, import, or create BSO
          if (matched_id = match_biological_specimen(attrs))
            @biological_specimen_id = matched_id
            @biological_specimen_imported = false
            @biological_specimen_params = nil
          elsif attrs[:occurrence_id].present? && (params = import_bso_idigbio(attrs[:occurrence_id])).present?
            @biological_specimen_id = nil
            @biological_specimen_imported = true
            @biological_specimen_params = params
          else
            @biological_specimen_id = nil
            @biological_specimen_imported = false
            @biological_specimen_params = bso_params_from_attrs(attrs)
          end
            
          # associate organization if a work is to be created
          if @biological_specimen_params.present? && @biological_specimen_id.nil?
            @biological_specimen_params.merge!(organization_id: @organization_id)
          end
        end

        def match_biological_specimen(attrs)
          if (
              attrs[:id].present? && 
              BiologicalSpecimen.find(attrs[:id])
            )
            return BiologicalSpecimen.find(attrs[:id]).id
          elsif (
              attrs[:occurrence_id] && 
              BiologicalSpecimen.where(occurrence_id: attrs[:occurrence_id]).present?
            )
            return BiologicalSpecimen.where(occurrence_id: attrs[:occurrence_id]).first.id
          elsif (
              attrs[:catalog_number].present? && 
              BiologicalSpecimen.where(
                catalog_number: attrs[:catalog_number],
                collection_code: attrs[:collection_code],
                institution_code: attrs[:institution_code]
              ).present?
            )
            return BiologicalSpecimen.where(
              catalog_number: attrs[:catalog_number],
              collection_code: attrs[:collection_code],
              institution_code: attrs[:institution_code]
            ).first.id
          else
            return nil
          end
        end

        def import_bso_idigbio(occurrence_id)
          Morphosource::IDigBioSearchService.biological_specimen_params_from_occurrence_id(occurrence_id)
        end

        def bso_params_from_attrs(attrs)
          Importer::Factory::BiologicalSpecimenFactory.new(
            attrs.except(:id).merge(depositor: depositor.user_key)
          ).create_attributes
        end
      end
    end
  end
end