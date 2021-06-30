module MassIngest
  module ConvertedMs1Batch
    module Models
      # Takes initial imaging event attrs and creates new attributes for work creation
      class ImagingEvent
        attr_accessor :initial_attrs, :device_id, :device_modality, :depositor, :attrs

        def initialize(initial_attrs, device_id, device_modality, depositor)
          @initial_attrs = initial_attrs
          @device_id = device_id
          @device_modality = device_modality
          @depositor = depositor

          @attrs = create_new_attributes if initial_attrs.present?
        end

        def create_new_attributes
          addl_attrs = { 
            device_id: device_id,
            device_modality: device_modality,
            depositor: depositor.user_key
          }

          Importer::Factory::ImagingEventFactory.new(
            initial_attrs.except(:id).merge(addl_attrs)
          ).create_attributes
        end
      end
    end
  end
end