module BatchSubmissionTools
  module Ms2Batch
    module Models
      # Takes initial imaging event attrs and creates new attributes for work creation
      class ImagingEventManifest
        attr_accessor :initial_attrs, :device_id, :device_modality, :depositor, :on_behalf_of, :attrs

        def initialize(initial_attrs: {}, device_id: nil, device_modality: nil, depositor: nil, on_behalf_of: nil, attrs: {}, **kwargs)
          @initial_attrs = initial_attrs
          @device_id = device_id
          @device_modality = device_modality
          @depositor = depositor
          @on_behalf_of = on_behalf_of
          
          if !attrs.present? && initial_attrs.present?
            @attrs = create_new_attributes
          else
            @attrs = attrs
          end
        end

        def create_new_attributes
          addl_attrs = { 
            device_id: device_id,
            ie_modality: device_modality,
            depositor: depositor,
            on_behalf_of: on_behalf_of
          }

          BatchSubmissionsImporter::Factory::ImagingEventFactory.new(
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