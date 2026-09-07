# frozen_string_literal: true
module Morphosource
  module Transactions
    module ImagingEvent
      module Steps
        ##
        # A step that sets the title for an imaging event ChangeSet based on other imaging event fields.
        class SetTitle
          include Dry::Monads[:result]

          ##
          # @param [Hyrax::ChangeSet] obj
          #
          # @return [Dry::Monads::Result]
          def call(obj)
            return Failure[:not_imaging_event_change_set, obj] unless obj.is_a?(ImagingEventResourceForm)

            obj.title = [generated_title(obj)]

            Success(obj)
          end

          private

          def generated_title(obj)
            device_info = ''
            if Array(obj.device_id).first.present?
              begin
                device = DeviceResource.find(Array(obj.device_id).first)
                device_info += "#{device.creator.first} " if device.creator.present?
                device_info += "#{device.title.first} " if device.title.present?
              rescue Valkyrie::Persistence::ObjectNotFoundError
                # leave device_info blank if device can't be found
              end
            end
            modality = Array(obj.ie_modality).first.present? ? "#{Array(obj.ie_modality).first} " : ''
            date_created = Array(obj.date_created).first.presence || 'No Event Date'
            "IE#{obj.id}: #{device_info}#{modality}Imaging Event (#{date_created})"
          end
        end
      end
    end
  end
end
