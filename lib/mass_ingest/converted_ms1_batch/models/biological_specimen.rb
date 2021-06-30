module MassIngest
  module ConvertedMs1Batch
    module Models
      # Takes initial biological specimen attrs and matches to existing, imports from iDigBio, or creates new attributes to work creation
      class BiologicalSpecimen
        attr_accessor :initial_attrs, :depositor, :organization_id
        attr_accessor :id, :work, :work_imported, :attrs
        attr_accessor :occurrence_id, :idigbio_uuid, :institution_code, :collection_code, :catalog_number

        def initialize(initial_attrs, depositor, organization_id)
          @initial_attrs = initial_attrs
          @depositor = depositor
          @organization_id = organization_id

          if initial_attrs.present? && depositor.present? && organization_id.present?
            prepare_ingest
          end
        end

        def prepare_ingest
          # match, import, or create BSO
          if work.present?
            @id = work.id
            @work_imported = false
            @attrs = nil
            @occurrence_id = work.occurrence_id&.first
            @idigbio_uuid = work.idigbio_id&.first
            @institution_code = work.institution_code&.first
            @collection_code = work.collection_code&.first
            @catalog_number = work.catalog_number&.first
          elsif initial_attrs[:occurrence_id].present? && (imported_attrs = import_work).present?
            @id = nil
            @work_imported = true
            @attrs = imported_attrs
            @occurrence_id = attrs['occurrence_id']
            @idigbio_uuid = attrs['idigbio_uuid']
            @institution_code = attrs['institution_code']
            @collection_code = attrs['collection_code']
            @catalog_number = attrs['catalog_number']
          else
            @id = nil
            @work_imported = false
            @attrs = create_new_attributes
            @occurrence_id = attrs[:occurrence_id]&.first
            @idigbio_uuid = attrs[:idigbio_uuid]&.first
            @institution_code = attrs[:institution_code]&.first
            @collection_code = attrs[:collection_code]&.first
            @catalog_number = attrs[:catalog_number]&.first
          end
            
          # associate organization if a work is to be created
          if @attrs.present? && @id.nil?
            @attrs.merge!(
              organization_id: [@organization_id],
              depositor: @depositor.user_key
            )
          end
        end

        def work
          @work ||=
            if (
                initial_attrs[:id].present? && 
                ::BiologicalSpecimen.exists?(initial_attrs[:id]&.first)
              )
              ::BiologicalSpecimen.find(initial_attrs[:id])
            elsif (
                initial_attrs[:occurrence_id].present? && 
                ( oi_bsos = ::BiologicalSpecimen.where(
                    occurrence_id: initial_attrs[:occurrence_id]
                  )
                ).present?
              )
              oi_bsos.first
            elsif (
                initial_attrs[:catalog_number].present? && 
                ( cc_bsos = ::BiologicalSpecimen.where(
                    catalog_number: initial_attrs[:catalog_number],
                    collection_code: initial_attrs[:collection_code],
                    institution_code: initial_attrs[:institution_code]
                  )
                ).present?
              )
              cc_bsos.first
            else
              nil
            end
        end

        def import_work
          Morphosource::IDigBioSearchService.biological_specimen_params_from_occurrence_id(initial_attrs[:occurrence_id])
        end

        def create_new_attributes
          Importer::Factory::BiologicalSpecimenFactory.new(initial_attrs.except(:id)).create_attributes
        end
      end
    end
  end
end