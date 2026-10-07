module BatchSubmissionsImporter
  module Factory
    class ImagingEventFactory < ObjectFactory
      include WithAssociatedCollection

      # TODO: Remove klass and valkyrie_klass (collapsing to just klass = ImagingEventResource) when all ImagingEvents have been migrated to ImagingEventResource
      self.klass = ImagingEvent
      self.valkyrie_klass = ImagingEventResource

    end
  end
end
