module Morphosource
  module Catalog
    class DevicesCatalogSearchBuilder < Morphosource::CatalogSearchBuilder

    private

      def models
        [::Device]
      end

    end
  end
end