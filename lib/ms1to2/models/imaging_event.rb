module Ms1to2
  module Models
    class ImagingEvent < BaseObject
      def mappings
        {
          :scanner_calibration_description => :description,
          :scanner_technicians => :creator,
          :scanner_exposure_time => :exposure_time,
          :scanner_calibration_flux_normalization => :flux_normalization,
          :scanner_calibration_geometric_calibration => :geometric_calibration,
          :scanner_calibration_shading_correction => :shading_correction,
          :normalized_filter => :filter,
          :scanner_frame_averaging => :frame_averaging,
          :scanner_projections => :projections,
          :scanner_voltage => :voltage,
          :scanner_amperage => :amperage,
          :scanner_wedge => :surrounding_material,
          :created_on => :date_uploaded
        }
      end

      def control_vocab_mappings
        {
          :scanner_calibration_flux_normalization => {
            '1' => 'Yes',
            '0' => 'No'
          },
          :scanner_calibration_geometric_calibration => {
            '1' => 'Yes',
            '0' => 'No'
          },
          :scanner_calibration_shading_correction => {
            '1' => 'Yes',
            '0' => 'No'
          }
        }
      end

      def expected_special_fields
        [:depositor, :parent_id, :ie_modality, :power]
      end
    end
  end
end