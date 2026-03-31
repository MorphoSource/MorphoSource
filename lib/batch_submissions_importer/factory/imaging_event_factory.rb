module BatchSubmissionsImporter
  module Factory
    class ImagingEventFactory < ObjectFactory
      include WithAssociatedCollection

      self.klass = ImagingEvent
      self.valkyrie_klass = ImagingEventResource

    end
  end
end
