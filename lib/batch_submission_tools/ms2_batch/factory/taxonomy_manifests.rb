module BatchSubmissionTools
  module Ms2Batch
    module Factory
      # Create 1+ taxonomy params model instances from input attributes and optional iDigBio UUID
      class TaxonomyManifests
        attr_accessor :attrs, :admin_user, :depositor, :on_behalf_of, :idigbio_uuid
        attr_accessor :ingests, :works_attrs

        def self.call(attrs:, admin_user:, depositor:, on_behalf_of: nil, idigbio_uuid: nil)
          new(
            attrs: attrs, 
            admin_user: admin_user,
            depositor: depositor,
            on_behalf_of: on_behalf_of,
            idigbio_uuid: idigbio_uuid
          ).call
        end

        def initialize(attrs:, admin_user:, depositor:, on_behalf_of: nil, idigbio_uuid: nil)
          @attrs = attrs
          @admin_user = admin_user
          @depositor = depositor
          @on_behalf_of = on_behalf_of
          @idigbio_uuid = idigbio_uuid
          @ingests = [] 
        end

        def call
          if idigbio_uuid.present?
            import_works_attrs
          else
            new_work_attrs
          end

          return ingests
        end

        def import_works_attrs
          # Import taxonomies from iDigBio
          provider_attrs = works_attrs[:provider].transform_keys(&:to_sym)
          gbif_attrs = works_attrs[:gbif].transform_keys(&:to_sym)

          new_work_attrs if !provider_attrs.present? && !gbif_attrs.present?

          if provider_attrs.present?
            existing_provider_work = Morphosource::TaxonomySearchService.match_taxonomies_strict(provider_attrs)
            if existing_provider_work&.first.present?
              # Taxonomy matching provider taxon exists, create ingest as matching and canonical
              new_ingest(ingest_attrs: { id: [existing_provider_work&.first.id] } , depositor: admin_user, canonical: true)
            else
              # No taxonomy matching provider taxon exists, create ingest as new canonical work to be created
              new_ingest(ingest_attrs: provider_attrs, depositor: admin_user, canonical: true)
            end
          end

          if gbif_attrs.present?
            existing_gbif_work = Morphosource::TaxonomySearchService.call({ gbif_key: gbif_attrs[:gbif_key] })
            if existing_gbif_work&.first.present?
              # Taxonomy matching GBIF taxon exists, create ingest as matching
              new_ingest(ingest_attrs: { id: [existing_gbif_work&.first.id] } , depositor: admin_user)
            else
              # No taxonomy matching GBIF taxon exists, create ingest as new work to be created
              new_ingest(ingest_attrs: gbif_attrs, depositor: admin_user)

            end
          end
        end

        def works_attrs
          @works_attrs ||= 
            Morphosource::IDigBioSearchService.taxonomy_param_sets_from_idigbio(idigbio_uuid)
        end

        def new_work_attrs
          new_ingest(ingest_attrs: attrs, depositor: depositor, on_behalf_of: on_behalf_of)
        end

        def new_ingest(ingest_attrs:, depositor:, on_behalf_of: nil, canonical: false)
          ingests << BatchSubmissionTools::Ms2Batch::Models::TaxonomyManifest.new(
            initial_attrs: ingest_attrs, 
            depositor: depositor,
            on_behalf_of: on_behalf_of,
            canonical: canonical
          )
        end
      end
    end
  end
end