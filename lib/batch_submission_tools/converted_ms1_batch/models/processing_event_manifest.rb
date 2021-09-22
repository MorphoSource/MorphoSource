module BatchSubmissionTools
  module ConvertedMs1Batch
    module Models
      class ProcessingEventManifest
        attr_accessor :initial_attrs, :depositor, :on_behalf_of, :attrs

        def initialize(initial_attrs: {}, depositor: nil, on_behalf_of: nil, attrs: {}, **kwargs)
          @initial_attrs = initial_attrs
          @depositor = depositor
          @on_behalf_of = on_behalf_of
          if !attrs.present? && initial_attrs.present?
            @attrs = create_new_attributes
          else
            @attrs = attrs
          end
        end

        def create_new_attributes
          addl_attrs = { depositor: depositor, on_behalf_of: on_behalf_of }

          Importer::Factory::ProcessingEventFactory.new(
            initial_attrs.except(:id).merge(addl_attrs)
          ).create_attributes
        end

        def to_h
          instance_values.symbolize_keys
        end
      end
    end
  end
end