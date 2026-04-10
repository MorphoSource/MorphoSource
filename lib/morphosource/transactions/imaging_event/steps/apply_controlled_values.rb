# frozen_string_literal: true
module Morphosource
  module Transactions
    module ImagingEvent
      module Steps
        ##
        # A step that normalizes controlled vocabulary values on an imaging event ChangeSet.
        class ApplyControlledValues
          include Dry::Monads[:result]

          CONTROLLED_ATTRIBUTES = {
            pixel_spacing_calibration: -> { Morphosource::PixelSpacingCalibrationService.new },
            target_type:              -> { Morphosource::TargetTypesService.new },
            detector_type:            -> { Morphosource::DetectorTypesService.new },
            detector_configuration:   -> { Morphosource::DetectorConfigurationService.new },
            acquisition_type:         -> { Morphosource::AcquisitionTypesService.new },
            focal_length_type:        -> { Morphosource::FocalLengthTypesService.new },
            light_source:             -> { Morphosource::LightSourceService.new }
          }.freeze

          ##
          # @param [Hyrax::ChangeSet] obj
          #
          # @return [Dry::Monads::Result]
          def call(obj)
            CONTROLLED_ATTRIBUTES.each do |attr, service_builder|
              next unless obj.respond_to?(attr) && obj.respond_to?(:"#{attr}=")

              service = service_builder.call
              normalized = Array(obj.send(attr)).map { |e| e ? service.controlled_value(e.strip) : e }
              obj.send(:"#{attr}=", normalized)
            end

            Success(obj)
          rescue StandardError => e
            Failure([:apply_controlled_values_failed, obj])
          end
        end
      end
    end
  end
end
