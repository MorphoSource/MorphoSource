module Importer
  module Factory
    class ProcessingEventFactory < ObjectFactory
      include WithAssociatedCollection

      self.klass = ProcessingEvent

    end
  end
end
