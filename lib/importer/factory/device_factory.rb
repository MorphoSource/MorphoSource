module Importer
  module Factory
    class DeviceFactory < ObjectFactory
      include WithAssociatedCollection

      self.klass = Device

    end
  end
end
