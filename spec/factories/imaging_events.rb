FactoryBot.define do
  # Valkyrie ImagingEvent resource work
  factory :imaging_event_resource, class: ImagingEventResource do
    title { ["example imaging event title"] }
    visibility { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
    depositor { nil }
    ie_modality { ["MagneticResonanceImaging"] }
    physical_object_id { ["000"] }

    transient do
      with_index { true }
      device { FactoryBot.valkyrie_create(:device_resource, modality: ie_modality) }
    end

    device_id { [device.id.to_s] }

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

  factory :imaging_event do
    # MorphoSource FactoryBehavior methods
    # see config/initializers/factory_bot.rb
    after_create_work # provides find methods for work

    title { ["example imaging event title"] }
    visibility { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
    depositor { nil }
    ie_modality { ["MagneticResonanceImaging"] }
    physical_object_id { ["000"] }
  end
end
