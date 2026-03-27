FactoryBot.define do
  factory :device do
    # MorphoSource FactoryBehavior methods
    # see config/initializers/factory_bot.rb
    after_create_work # provides find methods for work

    title { ["example device title"] }
    visibility { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
    depositor { nil }
    modality { ["BornDigital", "ConfocalImageStacking", "Infrared", "LaserAidedProfiling", "LaserScan", "LightSheetFluorescenceMicroscopy", "MagneticResonanceImaging", "MicroNanoXRayComputedTomography", "NeutronComputedTomography", "Photogrammetry", "Photography", "PositronEmissionTomography", "ReflectanceTransformationImaging", "ScanningElectronMicroscopy", "SequentialSectionScan", "SinglePhotonEmissionComputedTomography", "StructuredLight", "TransmissionElectronMicroscopy", "Video", "XRay"] }
  end

end
