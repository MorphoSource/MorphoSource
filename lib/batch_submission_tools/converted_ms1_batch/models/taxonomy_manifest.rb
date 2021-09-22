module BatchSubmissionTools
  module ConvertedMs1Batch
    module Models
      # Takes initial taxonomy attrs and matches to existing or creates new attributes for work creation
      class TaxonomyManifest
        attr_accessor :initial_attrs, :depositor, :on_behalf_of, :canonical, :id, :work, :attrs

        def initialize(initial_attrs: {}, depositor: nil, on_behalf_of: nil, canonical: false, id: nil, attrs: {}, **kwargs)
          @initial_attrs = initial_attrs
          @depositor = depositor
          @on_behalf_of = on_behalf_of
          @canonical = canonical
          @id = initial_attrs[:id]&.first || id
          @work = work
          if !attrs.present? && !work.present? && initial_attrs.present?
            @attrs = create_new_attributes
          else
            @attrs = attrs
          end
        end

        def work
          @work ||= ::Taxonomy.find(id) if id.present? && ::Taxonomy.exists?(id) 
        end

        def create_new_attributes
          addl_attrs = { depositor: depositor, on_behalf_of: on_behalf_of }

          Importer::Factory::TaxonomyFactory.new(
            initial_attrs.except(:id).merge(addl_attrs)
          ).create_attributes
        end

        def to_h
          instance_values.symbolize_keys.except(:work)
        end
      end
    end
  end
end