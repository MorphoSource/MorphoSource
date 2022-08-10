module BatchSubmissionTools
  module Ms2Batch
    module Models
      # Takes initial biological specimen attrs and matches to existing, imports from iDigBio, or creates new attributes to work creation
      class BiologicalSpecimenManifest
        attr_accessor :initial_attrs, :depositor, :on_behalf_of, :organization_id
        attr_accessor :id, :work, :work_imported, :attrs
        attr_accessor :occurrence_id, :idigbio_uuid, :institution_code, :collection_code, :catalog_number

        def initialize(initial_attrs: {}, depositor: nil, on_behalf_of: nil, organization_id: nil, id: nil, attrs: {}, work_imported: false, **kwargs)
          @initial_attrs = initial_attrs
          @depositor = depositor
          @on_behalf_of = on_behalf_of
          @organization_id = organization_id
          @id = initial_attrs[:ms_id]&.first || id
          @work = work
          @work_imported = work_imported
          @attrs = attrs

          # match, import, or create BSO
          if attrs.present?
            @occurrence_id = @attrs[:occurrence_id]&.first || @attrs['occurrence_id']
            @idigbio_uuid = @attrs[:idigbio_uuid]&.first || @attrs['idigbio_uuid']
            @institution_code = @attrs[:institution_code]&.first || @attrs['institution_code']
            @collection_code = @attrs[:collection_code]&.first || @attrs['collection_code']
            @catalog_number = @attrs[:catalog_number]&.first || @attrs['catalog_number']
          elsif work.present?
            @id = work.id
            @work_imported = false
            @occurrence_id = work.occurrence_id&.first
            @idigbio_uuid = work.idigbio_uuid&.first
            @institution_code = work.institution_code&.first
            @collection_code = work.collection_code&.first
            @catalog_number = work.catalog_number&.first
          elsif initial_attrs[:occurrence_id].present? && (imported_attrs = import_work).present?
            @attrs = imported_attrs.merge( 
              organization_id: [@organization_id],
              depositor: @depositor,
              on_behalf_of: @on_behalf_of,
              description: description(imported_attrs),
              idigbio_link_origin: ["user"]
            )
            @work_imported = true
            @occurrence_id = @attrs['occurrence_id']
            @idigbio_uuid = @attrs['idigbio_uuid']
            @institution_code = @attrs['institution_code']
            @collection_code = @attrs['collection_code']
            @catalog_number = @attrs['catalog_number']
          elsif !attrs.present? && initial_attrs.present?
            @attrs = create_new_attributes.merge( 
              organization_id: [@organization_id],
              depositor: @depositor,
              on_behalf_of: @on_behalf_of,
              description: description(initial_attrs)
            )
            @work_imported = false
            @occurrence_id = @attrs[:occurrence_id]&.first
            @idigbio_uuid = @attrs[:idigbio_uuid]&.first
            @institution_code = @attrs[:institution_code]&.first
            @collection_code = @attrs[:collection_code]&.first
            @catalog_number = @attrs[:catalog_number]&.first
          end
        end

        def description(attributes)
          if attributes[:description].present?
            attributes[:description].first.to_s + "\r\n\r\n" + description_text
          else
            description_text
          end
        end

        def description_text
          'Record created by batch submission.'
        end

        def work
          # if specimen ms_id exists, get the object and ignore other BSO columns (occur id, coll code, catalog num, etc) 
          @work ||=
            if (
                id.present? && 
                ::BiologicalSpecimen.exists?(id)
              )
              ::BiologicalSpecimen.find(id)
            elsif (
                initial_attrs[:occurrence_id].present? && 
                ( oi_bsos = ::BiologicalSpecimen.where(
                    occurrence_id: initial_attrs[:occurrence_id].to_s
                  )
                ).present?
              )
              oi_bsos.first
            elsif (
                initial_attrs[:catalog_number].present? && 
                ( cc_bsos = ::BiologicalSpecimen.where(
                    catalog_number: initial_attrs[:catalog_number].to_s,
                    collection_code: initial_attrs[:collection_code].to_s,
                    institution_code: initial_attrs[:institution_code].to_s
                  )
                ).present?
              )
              cc_bsos.first
            else
              nil
            end
        end

        def import_work
          result, idb_records = ::Morphosource::IDigBioSearchService.biological_specimen_params_from_occurrence_id(initial_attrs[:occurrence_id])
          return result
        end

        def create_new_attributes
          ::Importer::Factory::BiologicalSpecimenFactory.new(
            initial_attrs.except(:id)
          ).create_attributes
        end

        def to_h
          instance_values.symbolize_keys.except(:work)
        end
      end
    end
  end
end