module MassIngest
  module ConvertedMs1Batch
    module Models
      # Takes multiple individual-media hashes, generates params with relationships and ordering
      class BiologicalSpecimen
        attr_accessor :bso_hash, :depositor, :organization_id
        attr_accessor :biological_specimen_id, :biological_specimen_matched
        attr_accessor :biological_specimen_imported, :biological_specimen_params
        attr_accessor :occurrence_id, :institution_code, :collection_code, :catalog_number

        def initialize(bso_hash, depositor, organization_id)
          @bso_hash = bso_hash
          @depositor = depositor
          @organization_id = organization_id

          if bso_hash.present? && depositor.present? && organization_id.present?
            construct_biological_specimen_ingest
          end
        end

        def construct_biological_specimen_ingest

          # match, import, or create BSO
          if (matched_specimen = match_biological_specimen(bso_hash))
            @biological_specimen_id = matched_specimen.id
            @biological_specimen_matched = matched_specimen
            @biological_specimen_imported = false
            @biological_specimen_params = nil
            @occurrence_id = matched_specimen.occurrence_id&.first
            @institution_code = matched_specimen.institution_code&.first
            @collection_code = matched_specimen.collection_code&.first
            @catalog_number = matched_specimen.catalog_number&.first
          elsif bso_hash[:occurrence_id].present? && (params = import_bso_idigbio(bso_hash[:occurrence_id])).present?
            @biological_specimen_id = nil
            @biological_specimen_matched = nil
            @biological_specimen_imported = true
            @biological_specimen_params = params
            @occurrence_id = params['occurrence_id']
            @institution_code = params['institution_code']
            @collection_code = params['collection_code']
            @catalog_number = params['catalog_number']
          else
            params = bso_params_from_attrs(bso_hash)
            @biological_specimen_id = nil
            @biological_specimen_matched = nil
            @biological_specimen_imported = false
            @biological_specimen_params = params
            @occurrence_id = params[:occurrence_id]&.first
            @institution_code = params[:institution_code]&.first
            @collection_code = params[:collection_code]&.first
            @catalog_number = params[:catalog_number]&.first
          end
            
          # associate organization if a work is to be created
          if @biological_specimen_params.present? && @biological_specimen_id.nil?
            @biological_specimen_params.merge!(
              organization_id: @organization_id,
              depositor: @depositor
            )
          end
        end

        def match_biological_specimen(attrs)
          if (
              attrs[:id].present? && 
              ::BiologicalSpecimen.exists?(attrs[:id])
            )
            ::BiologicalSpecimen.find(attrs[:id])
          elsif (
              attrs[:occurrence_id].present? && 
              ( oi_bsos = ::BiologicalSpecimen.where(
                  occurrence_id: attrs[:occurrence_id]
                )
              ).present?
            )
            oi_bsos.first
          elsif (
              attrs[:catalog_number].present? && 
              ( cc_bsos = ::BiologicalSpecimen.where(
                  catalog_number: attrs[:catalog_number],
                  collection_code: attrs[:collection_code],
                  institution_code: attrs[:institution_code]
                )
              ).present?
            )
            cc_bsos.first
          else
            nil
          end
        end

        def import_bso_idigbio(occurrence_id)
          Morphosource::IDigBioSearchService.biological_specimen_params_from_occurrence_id(occurrence_id)
        end

        def bso_params_from_attrs(attrs)
          Importer::Factory::BiologicalSpecimenFactory.new(attrs.except(:id)).create_attributes
        end
      end
    end
  end
end