module Morphosource
  module Catalog
    class DevicesCatalogSearchBuilder < Morphosource::CatalogSearchBuilder

    private

      def models
        [::Device, ::DeviceResource]
      end

    end
  end
end
