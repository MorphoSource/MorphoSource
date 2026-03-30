FactoryBot.define do
  # Valkyrie Device resource work
  factory :device_resource, class: DeviceResource do
    title       { ["example device title"] }
    visibility  { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
    depositor   { nil }
    modality    { ["XRay"] }

    transient do
      with_index { true }
    end

    after(:create) do |work, evaluator|
      if evaluator.with_index
        work.permission_manager.acl.save
      else
        # manually save acl change_set so it does not automatically index the work
        change_set = work.permission_manager.acl.send(:change_set)
        change_set.sync
        Hyrax.persister.save(resource: change_set.resource)
      end

      Hyrax.index_adapter.save(resource: Hyrax.query_service.find_by(id: work.id)) if evaluator.with_index
    end
  end

  # ActiveFedora Device work
  factory :device do
    # MorphoSource FactoryBehavior methods
    # see config/initializers/factory_bot.rb
    after_create_work # provides find methods for work

    title { ["example device title"] }
    visibility { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
    depositor { nil }
    modality { ["BornDigital", "ConfocalImageStacking", "Infrared", "LaserAidedProfiling", "LaserScan", "LightSheetFluorescenceMicroscopy", "MagneticResonanceImaging", "MicroNanoXRayComputedTomography", "NeutronComputedTomography", "Photogrammetry", "Photography", "PositronEmissionTomography", "ReflectanceTransformationImaging", "ScanningElectronMicroscopy", "SequentialSectionScan", "SinglePhotonEmissionComputedTomography", "StructuredLight", "TransmissionElectronMicroscopy", "Video", "XRay"] }

    after(:create) do |device|
      # find device by id
      ::RSpec::Mocks.allow_message(device.class, :find).with(device.id).and_return(device)
      ::RSpec::Mocks.allow_message(device.class, :find).with([device.id]).and_return([device])
    end
  end

end
