module MassIngest
  module ConvertedMs1Batch
    module Models
      # Takes initial taxonomy attrs and matches to existing or creates new attributes for work creation
      class Taxonomy
        attr_accessor :initial_attrs, :depositor, :canonical, :id, :work, :attrs

        def initialize(initial_attrs, depositor, canonical = false)
          @initial_attrs = initial_attrs
          @depositor = depositor
          @canonical = canonical

          prepare_ingest if initial_attrs.present?
        end

        def prepare_ingest
          if initial_attrs[:id]&.first.present? && Taxonomy.exists?(initial_attrs[:id]&.first)
            # match
            matched_taxonomy = Taxonomy.find(initial_attrs[:id]&.first)
            @id = matched_taxonomy.id
            @work = matched_taxonomy
            @attrs = nil
          else
            # create new
            @id = nil
            @work = nil
            @attrs = create_new_attributes
          end
        end

        def create_new_attributes
          addl_attrs = { depositor: depositor.user_key }

          Importer::Factory::TaxonomyFactory.new(
            initial_attrs.except(:id).merge(addl_attrs)
          ).create_attributes
        end

        def to_h
          instance_values.transform_keys(&:to_sym)
        end
      end
    end
  end
end