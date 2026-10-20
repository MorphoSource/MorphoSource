module BatchSubmissionTools
  module Ms2Batch
    module Factory
      # Create 1+ taxonomy params model instances from input attributes and optional taxonomy imported with the BSO
      class TaxonomyManifests
        attr_accessor :attrs, :admin_user, :depositor, :on_behalf_of, :imported_taxonomy_param_sets
        attr_accessor :ingests

        # @param imported_taxonomy_param_sets [Hash] { provider: {...}, gbif: {...} } from the BSO's remote record
        def self.call(attrs:, admin_user:, depositor:, on_behalf_of: nil, imported_taxonomy_param_sets: nil)
          new(
            attrs: attrs, 
            admin_user: admin_user,
            depositor: depositor,
            on_behalf_of: on_behalf_of,
            imported_taxonomy_param_sets: imported_taxonomy_param_sets
          ).call
        end

        def initialize(attrs:, admin_user:, depositor:, on_behalf_of: nil, imported_taxonomy_param_sets: nil)
          @attrs = attrs
          @admin_user = admin_user
          @depositor = depositor
          @on_behalf_of = on_behalf_of
          @imported_taxonomy_param_sets = imported_taxonomy_param_sets
          @ingests = [] 
        end

        def call
          if imported_taxonomy_param_sets.present?
            import_works_attrs
          else
            new_work_attrs
          end

          return ingests
        end

        def import_works_attrs
          linker = Morphosource::SpecimenSources::TaxonomyLinker.call(imported_taxonomy_param_sets)

          if linker.taxonomy_id_array.empty? && linker.taxonomy_params_array.empty?
            new_work_attrs
            return
          end

          # Existing taxonomies, create ingests as matching
          linker.taxonomy_id_array.each do |taxonomy_id|
            new_ingest(ingest_attrs: { id: [taxonomy_id] }, depositor: admin_user, canonical: taxonomy_id == linker.canonical_taxonomy_id)
          end

          # New taxonomies, create ingests as new works to be created
          linker.taxonomy_params_array.each do |taxonomy_params|
            ingest_attrs = taxonomy_params.to_unsafe_h.symbolize_keys
            canonical = ingest_attrs.delete(:canonical).present?
            new_ingest(ingest_attrs: ingest_attrs, depositor: admin_user, canonical: canonical)
          end
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