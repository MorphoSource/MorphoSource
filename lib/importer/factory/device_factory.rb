module Importer
  module Factory
    class DeviceFactory < ObjectFactory
      include WithAssociatedCollection

      self.klass = Device
      self.valkyrie_klass = DeviceResource

    end
  end
end
