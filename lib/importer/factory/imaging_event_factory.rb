module Importer
  module Factory
    class ImagingEventFactory < ObjectFactory
      include WithAssociatedCollection

      self.klass = ImagingEvent

    end
  end
end
