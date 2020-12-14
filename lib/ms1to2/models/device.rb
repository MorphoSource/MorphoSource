module Ms1to2
  module Models
    class Device < BaseObject
      def mappings
        {
          :description => :description,
          :modality => :modality,
          :created_on => :date_uploaded
        }
      end

      def control_vocab_mappings
        {
          :modality => {
            'MicroNanoXRayComputedTomography' => 'MicroNanoXRayComputedTomography',
            'MagneticResonanceImaging' => 'MagneticResonanceImaging',
            'PositronEmissionTomography' => 'PositronEmissionTomography',
            'SinglePhotonEmissionComputedTomography' => 'SinglePhotonEmissionComputedTomography',
            'NeutronComputedTomography' => 'NeutronComputedTomography',
            'SynchrotronImaging' => 'SynchrotronImaging',
            'Photogrammetry' => 'Photogrammetry',
            'StructuredLight' => 'StructuredLight',
            'LaserScan' => 'LaserScan',
            'ConfocalImageStacking' => 'ConfocalImageStacking',
            'Infrared' => 'Infrared',
            'ReflectanceTransformationImaging' => 'ReflectanceTransformationImaging',
            'Photography' => 'Photography',
            'ScanningElectronMicroscopy' => 'ScanningElectronMicroscopy',
            'BornDigital' => 'BornDigital',
            'Xray' => 'XRay',
            'XRay' => 'XRay',
            'LaserAidedProfiling' => 'LaserAidedProfiling',
            'Video' => 'Video'
          }
        }
      end

      def expected_special_fields
        [:depositor, :parent_id, :title, :creator]
      end
    end
  end
end